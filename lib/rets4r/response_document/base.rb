require 'nokogiri'
require 'rexml/document'

require 'rets4r/client/exceptions'
require 'rets4r/client/transaction'

module RETS4R
  module ResponseDocument
    # A ResponseDocument is a Nokogiri XML Document that lets you access all the
    # important information in a RETS service response. This is a DOM style API,
    # so if you have large files to handle or experience performance issues, you
    # should consider switching to RETS4R::Client::CompactNokogiriParser::CompactDocument
    # which provides a SAX API
    class Base < Nokogiri::XML::Document
      # like #parse, but set the noblanks, noerror and recover options
      def self.safe_parse(*args)
        parse(*args) do |config|
          config.strict.noblanks
          config.strict.noerror
          config.strict.recover
        end
      end

      # true if the root element is named 'RETS'
      def rets?
        root && root.name == 'RETS'
      end

      # the reply code as an integer
      def reply_code
        root['ReplyCode'].to_i
      end

      # true if the reply code indicates success (is 0)
      def success?
        reply_code == 0
      end

      # the contents of the ReplyText attribute
      def reply_text
        root['ReplyText']
      end

      # true if the document has a MAXROWS element
      def max_rows?
        search('/RETS/MAXROWS').length > 0
      end

      # support transaction interface
      alias :maxrows? :max_rows?

      # true unless the response was a success (reply_code: 0) or found
      # no records (reply_code: 20201)
      def error?
        reply_code > 0 && reply_code != 20201
      end

      # true if there are no noticeable errors with the document. use
      # #validate! if you need to access the errors
      def valid?
        !blank? && rets? && !error?
      end

      # true if the document is not #valid?
      def invalid?
        !valid?
      end

      # raises exceptions if things are wrong. checks for
      # blank?  :: raises RETSException if the document is blank?
      # rets?   :: raises RETSException if the document is not rets?
      # error?  :: raises the relevant exception type if the reply_code indicates an error
      #
      # returns self, so you can chain this
      #--
      # TODO: write a validate that's consistant with the one in nokogiri
      def validate!
        raise Client::RETSException, 'No transaction body was returned.' if blank?

        raise Client::RETSException, "Response had invalid root node. Document was: #{inspect}" unless rets?

        if error?
          exception_type = Client::EXCEPTION_TYPES[reply_code] || Client::RETSTransactionException
          raise exception_type, "#{reply_code} - #{reply_text}"
        end
        self
      end

      # the value of the Records attribute in the COUNT element as an integer
      def count
        self.at('/RETS/COUNT')['Records'].to_i
      end

      # the ResponseDocument converted to a REXML::Document
      def to_rexml
        REXML::Document.new(to_s)
      end

      # a new transaction with the count as its response
      def parse_count
        to_transaction { count }
      end

      # a new transaction with the response parsed using the CompactDataParser
      def parse_results
        RETS4R::ResponseDocument::Search.parse(self.to_s).to_transaction
      end

      # a new transaction with the hash of the body in the response
      #--
      # TODO: put this in a LoginResponseDocument
      def parse_key_value
        to_transaction { to_h }
      end

      # the body of the document parsed into a hash. Intended for use with
      # Login responses
      #--
      # TODO: put this in a LoginResponseDocument
      def to_h
        pairs = first_child.text.each_line("\n").collect do |line|
          key, value = parse_key_value_line(line)
        end
        Hash[pairs]
      end

      # a new transaction from this document. An optional block will be
      # evaluated and placed in the transaction response, if provided
      def to_transaction
        Client::Transaction.new.tap do |t|
          t.reply_code = reply_code.to_s
          t.reply_text = reply_text
          t.maxrows = max_rows?
          t.doc = self
          t.response = yield if block_given?
        end
      end

      private
      # TODO: put this in a LoginResponseDocument
      def first_child
        self.at('/RETS/RETS-RESPONSE') or self.at('/RETS')
      end
      # TODO: put this in a LoginResponseDocument
      def parse_key_value_line(line)
        (key, value) = line.strip.split('=')
        key.strip! if key
        value.strip! if value
        [key, value]
      end
    end
  end
end
