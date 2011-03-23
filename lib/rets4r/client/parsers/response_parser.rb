require 'rets4r/client/transaction'
require 'rets4r/client/parsers/compact'
require 'rexml/document'

module RETS4R
  class Client
    class ResponseParser
      def parse_key_value(xml)
        ResponseDocument.safe_parse(xml).validate!.parse_key_value
      end

      def parse_results(xml, format)
        raise "Invalid format #{format}" unless %w(COMPACT COMPACT-DECODED).include? format
        ResponseDocument.safe_parse(xml).validate!.parse_results
      end

      def parse_count(xml)
        ResponseDocument.safe_parse(xml).validate!.parse_count
      end

      def parse_metadata(xml, format)
        ResponseDocument.safe_parse(xml).validate!.to_rexml
      end

      def parse_object_response(xml)
        ResponseDocument.safe_parse(xml).validate!.to_transaction
      end
    end
  end
end
