require 'rets4r/response_document/base'

module RETS4R
  module ResponseDocument
    # search response document. slower than sax, but easier to play with.
    class Search < Base
      include Enumerable

      # returns the column delimiter as an ASCII string
      #
      # Example
      # Search.parse('<RETS><DELIMITER value="09" /></RETS>).delimiter
      # => "\t"
      def delimiter
        at('/RETS/DELIMITER')['value'].to_i.chr
      end

      def headers
        split_raw_headers(at('/RETS/COLUMNS').text)
      end
      alias_method :columns, :headers

      def each #:yields: row
        each_raw_row {|row| yield row_to_hash(row) }
      end

      alias_method :results, :to_a

      def to_transaction
        super { to_a }
      end

      def self.split_raw_headers(string, delimiter)
        # compact always begins with a field delimiter, we can drop it
        string.split(delimiter)[1..-1]
      end

      def self.row_to_hash(string, headers, delimiter)
        items = string.split(delimiter)
        # compact always begins with a field delimiter, we can drop it
        items = items[1..-1]
        pairs = headers.zip(items).reject {|k,v| k.empty? }
        Hash[pairs]
      end

private
      def split_raw_headers(string)
        self.class.split_raw_headers(string, delimiter)
      end
      def row_to_hash(string)
        self.class.row_to_hash(string, headers, delimiter)
      end
      def each_raw_row #:yields: row
        search('/RETS/DATA').each {|row| yield row.text }
      end
    end
  end
end
