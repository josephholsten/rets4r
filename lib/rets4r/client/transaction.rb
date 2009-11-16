module RETS4R
  class Client
    class Transaction
      attr_accessor :reply_code, :reply_text, :response, :metadata,
        :header, :maxrows, :delimiter, :secondary_response

      def initialize
        self.maxrows = false
        self.header = []
        self.delimiter = ?\t
      end

      def success?
        return true if self.reply_code == '0'
        return false
      end

      def maxrows?
        return true if self.maxrows
        return false
      end

      def ascii_delimiter
        self.delimiter.chr
      end
    end
  end
end
