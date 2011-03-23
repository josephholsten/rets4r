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
        if xml == ''
          raise RETSException, 'No transaction body was returned!'
        end

        doc = Nokogiri::XML(xml) do |config|
          config.strict.noblanks
          config.strict.noerror
          config.strict.recover
        end

        root = doc.root
        if root.nil? || root.name != 'RETS'
          raise "Response had invalid root node. Document was: #{doc.inspect}"
        end

        transaction = Transaction.new
        transaction.reply_code = root['ReplyCode']
        transaction.reply_text = root['ReplyText']
        transaction.maxrows    = (doc.search('/RETS/MAXROWS').length > 0)

        # XXX: If it turns out we need to parse the response of errors, then this will
        # need to change.
        if transaction.reply_code.to_i > 0 && transaction.reply_code.to_i != 20201
          exception_type = Client::EXCEPTION_TYPES[transaction.reply_code.to_i] || RETSTransactionException
          raise exception_type, "#{transaction.reply_code} - #{transaction.reply_text}"
        end

        transaction.response = yield doc
        return transaction
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

