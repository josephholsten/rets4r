module RETS4R
  class Client
    class Transaction
      attr_accessor :reply_code, :reply_text, :response, :metadata,
        :header, :maxrows, :delimiter, :secondary_response, :doc

      def initialize
        self.maxrows = false
        self.header = []
        self.delimiter = ?\t
      end

      #--
      # TODO: delegate onto #doc
      def success?
        return true if self.reply_code == '0'
        return false
      end

      #--
      # TODO: delegate onto #doc
      def maxrows?
        return true if self.maxrows
        return false
      end

      def ascii_delimiter
        self.delimiter.chr
      end

      # For compatibility with the original library.
      alias :data :response
    end
  end
end
