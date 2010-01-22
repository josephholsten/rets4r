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
          when 'DATA'
            @data_element = true
          end
        end

        def end_element name
          case name
          when 'COLUMNS'
            @columns_element = false
          when 'DATA'
            @data_element = false
          end
        end

        def characters string
          if @columns_element
            @columns = string.split(@delimiter)
          elsif @data_element
            data = @columns.zip(string.split(@delimiter)).inject({}) do | h,(k,v) |
              h[k] = v unless k.empty?
              next h
            end
            @results << data
          end
        end
      end
    end
  end
end