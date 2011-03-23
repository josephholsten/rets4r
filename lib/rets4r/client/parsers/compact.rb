# Parses XML response containing 'COMPACT' data format.

require 'cgi'

module RETS4R
  class Client
    class CompactDataParser
      # Take an RETS XML Document and parse out its results
      def parse_results(doc)
        # TODO: replace with a a proper document class
        delimiter = doc.at('/RETS/DELIMITER') &&
                    doc.at('/RETS/DELIMITER')['value'].to_i.chr
        columns   = doc.at('/RETS/COLUMNS')
        rows      = doc.search('/RETS/DATA')

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
