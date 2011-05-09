require 'nokogiri'
module RETS4R
  class Client
    class CompactNokogiriParser
      include Enumerable
      def initialize(io)
        @doc    = CompactDocument.new
        @parser = Nokogiri::XML::SAX::Parser.new(@doc)
        @io     = io
      end

      def to_a
        @parser.parse(@io) if @doc.results.empty?
        @doc.results
      end

      def each(&block)
        @doc.proc = block.to_proc
        @parser.parse(@io)
        nil
      end

      class CompactDocument < Nokogiri::XML::SAX::Document
        attr_reader :results
        attr_writer :proc

        def initialize
          @results = []
        end
        def start_element name, attrs = []
          case name
          when 'DELIMITER'
            if attrs.last.respond_to?('last')
              @delimiter = attrs.last.last.to_i.chr
            else
              @delimiter = attrs.last.to_i.chr
            end
          when 'COLUMNS'
            @columns_element = true
            @string = ''
          when 'DATA'
            @data_element = true
            @string = ''
          when 'RETS'
            handle_body_start attrs
          end
        end

        def end_element name
          case name
          when 'COLUMNS'
            @columns_element = false
            @columns = @string.split(@delimiter)
          when 'DATA'
            @data_element = false
            handle_row
          end
        end

        def characters string
          if @columns_element
            @string << string
          elsif @data_element
            @string << string
          elsif @reply_code
            throw string
            @reply_code = false
          end
        end

        private
        def handle_row
          data = make_hash
          if @proc
            @proc.call(data)
          else
            @results << data
          end
        end
        def handle_body_start attrs
          attrs = Hash[*attrs]
          if exception_class = Client::EXCEPTION_TYPES[attrs['ReplyCode'].to_i]
            raise exception_class.new(attrs['ReplyText'])
          end
        end
        #--
        # What does this do? Could this be reused elsewhere?
        def make_hash
          @columns.zip(@string.split(@delimiter)).inject({}) do | h,(k,v) |
            h[k] = v unless k.empty?
            next h
          end
        end
      end
    end
  end
end
