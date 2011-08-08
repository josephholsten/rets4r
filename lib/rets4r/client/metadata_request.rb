module RETS4R
  class Client
    class MetadataRequest
      attr_accessor :uri, :method, :retry_auth, :client
      def initialize(uri, type, id, format, request_struct)
        @uri = uri
        @type = type
        @id = id
        @format = format
        @request_struct = request_struct
      end
      def request
        @request_struct.request(uri, data, header)
      end
      def data
        {
          'Type'   => @type,
          'ID'     => @id,
          'Format' => @format
        }
      end
      def header
        { 'Accept' => 'text/xml,text/plain;q=0.5' }
      end
    end
  end
end
