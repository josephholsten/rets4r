# Parses XML response containing 'COMPACT' data format.

require 'cgi'

module RETS4R
  class Client
    class CompactDataParser
      def parse_results(doc)

        delimiter = doc.get_elements('/RETS/DELIMITER')[0] &&
                    doc.get_elements('/RETS/DELIMITER')[0].attributes['value'].to_i.chr
        columns   = doc.get_elements('/RETS/COLUMNS')[0]
        rows      = doc.get_elements('/RETS/DATA')

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
