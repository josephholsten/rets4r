module RETS4R
  class Client
    class ObjectHeader < Hash
      include Net::HTTPHeader
      def initialize(raw_header)
        initialize_http_header( raw_header )
      end
    end
    # Represents a RETS object (as returned by the get_object) transaction.
    class DataObject
      
      attr_accessor :header, :data

      alias :type :header
      alias :info :type

      def initialize(headers, data)
        @header = ObjectHeader.new(headers) 
        @data = data
      end

      def success?
          return true if self.data
          return false
      end
    end
  end
end
