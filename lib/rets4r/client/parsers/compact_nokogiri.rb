require 'nokogiri'

require 'rets4r/client/exceptions'
require 'rets4r/response_document'

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
          @data_element = nil
          @reply_code = nil
          @columns_element = nil
          @proc = nil
        end
        def start_element name, attrs = []
          case name
          when 'DELIMITER'
            # This is a workaround for the old attribute handling in nokogiri
            @delimiter = if Array === attrs.last
               # In nokogiri >= 1.4.4, we recieve attributes as an assoc list,
               # which also includes the current namespaces in the context
              attrs.last.last.to_i.chr
            else
              if $VERBOSE
                warn "#{caller.first}: warning: support for Nokogiri <= 1.4.3.1 is deprecated and will be removed by rets4r 2.0; Please upgrade to Nokogiri 1.4.4 or newer"
              end
              # Earlier versions would flatten attributes, making it painful for
              # namespace aware parsing.
              attrs.last.to_i.chr
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
            @columns = RETS4R::ResponseDocument::Search.split_raw_headers(@string, @delimiter)
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
          # This is a workaround for the old attribute handling in nokogiri
          attrs = if Array === attrs.first
             # In nokogiri >= 1.4.4, we recieve attributes as an assoc list,
             # which also includes the current namespaces in the context
            Hash[attrs]
          else
            if $VERBOSE
              warn "#{caller.first}: warning: support for Nokogiri <= 1.4.3.1 is deprecated and will be removed by rets4r 2.0; Please upgrade to Nokogiri 1.4.4 or newer"
            end
            # Earlier versions would flatten attributes, making it painful for
            # namespace aware parsing.
            Hash[*attrs]
          end
          if exception_class = Client::EXCEPTION_TYPES[attrs['ReplyCode'].to_i]
            raise exception_class.new(attrs['ReplyText'])
          end
        end
        #--
        # What does this do? Could this be reused elsewhere?
        def make_hash
          RETS4R::ResponseDocument::Search.row_to_hash(@string, @columns, @delimiter)
        end
      end
    end
  end
end
