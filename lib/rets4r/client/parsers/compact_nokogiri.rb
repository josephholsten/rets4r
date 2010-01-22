require 'rubygems'
require 'nokogiri'
module RETS4R
  class Client
    class CompactNokogiriParser < Nokogiri::XML::SAX::Document
      def parse_results(file)
        doc = CompactDocument.new
        parser = Nokogiri::XML::SAX::Parser.new(doc)
        parser.parse_file(file)
        doc.results
      end
      class CompactDocument < Nokogiri::XML::SAX::Document
        attr_reader :results
        
        def initialize
          @results = []
        end
        def start_element name, attrs = []
          case name
          when 'DELIMITER'
            @delimiter = attrs.last.to_i.chr
          when 'COLUMNS'
            @columns_element = true
            @string = ''
          when 'DATA'
            @data_element = true
            @string = ''
          end
        end

        def end_element name
          case name
          when 'COLUMNS'
            @columns_element = false
            @columns = @string.split(@delimiter)
          when 'DATA'
            @data_element = false
            @results << @columns.zip(@string.split(@delimiter)).inject({}) do | h,(k,v) |
              h[k] = v unless k.empty?
              next h
            end
          end
        end

        def characters string
          if @columns_element
            @string << string
          elsif @data_element
            @string << string
          end
        end
      end
    end
  end
end