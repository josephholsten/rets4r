require 'rets4r/client/transaction'
require 'rets4r/client/parsers/compact'
require 'rexml/document'

module RETS4R
  class Client
    class ResponseParser
      def parse_key_value(xml)
        parse_common(xml) do |doc|
          parsed = nil
          first_child = if doc.at('/RETS/RETS-RESPONSE')
            doc.at('/RETS/RETS-RESPONSE')
          else
            doc.at('/RETS')
          end
          unless first_child.nil?
            parsed = {}
            first_child.text.each do |line|
              (key, value) = line.strip.split('=')
              key.strip! if key
              value.strip! if value
              parsed[key] = value
            end
          else
            raise 'Response was not a proper RETS XML doc!'
          end

          if parsed.nil?
            raise "Response was not valid key/value format"
          else
            parsed
          end
        end
      end

      def parse_results(xml, format)
        parse_common(xml) do |doc|
          parser = get_parser_by_name(format)
          parser.parse_results(doc)
        end
      end

      def parse_count(xml)
        parse_common(xml) do |doc|
          doc.at('/RETS/COUNT')['Records']
        end
      end

      def parse_metadata(xml, format)
        parse_common(xml) do |doc|
          return REXML::Document.new(xml)
        end
      end

      def parse_object_response(xml)
        parse_common(xml) do |doc|
          # XXX
        end
      end

      private

      def parse_common(xml, &block)
        doc = RETS4R::ResponseDocument.parse(xml) do |config|
          config.strict.noblanks
          config.strict.noerror
          config.strict.recover
        end

        doc.validate!

        transaction = doc.to_transaction {|response| yield response }
      end

      def get_parser_by_name(name)
        case name
          when 'COMPACT', 'COMPACT-DECODED'
            type = RETS4R::Client::CompactDataParser
          else
            raise "Invalid format #{name}"
        end
        type.new
      end
    end
  end
end

