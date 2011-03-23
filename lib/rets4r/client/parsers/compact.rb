# Parses XML response containing 'COMPACT' data format.

require 'cgi'

module RETS4R
  class Client
    class CompactDataParser
      def parse_results(doc)

        delimiter = doc.xpath('/RETS/DELIMITER')[0] &&
                    doc.xpath('/RETS/DELIMITER')[0]['value'].to_i.chr
        columns   = doc.xpath('/RETS/COLUMNS')[0]
        rows      = doc.xpath('/RETS/DATA')

        parse_data(columns, rows, delimiter)
      end

      def parse_data(column_element, row_elements, delimiter = "\t")

        column_names = column_element.to_s.split(delimiter)

        result = []

        data = row_elements.each do |data_row|
          data_row = data_row.text.split(delimiter)

          row_result = {}

          column_names.each_with_index do |col, x|
            row_result[col] = data_row[x]
          end

          row_result.reject! { |k,v| k.nil? || k.empty? }

          result << row_result
        end

        return result
      end
    end
  end
end
