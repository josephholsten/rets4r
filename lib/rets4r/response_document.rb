require 'rets4r/client/transaction'
require 'rets4r/client/exceptions'

module RETS4R
  class ResponseDocument < Nokogiri::XML::Document
    def rets?
      root && root.name == 'RETS'
    end
    def reply_code
      root['ReplyCode'].to_i
    end
    def reply_text
      root['ReplyText']
    end
    def max_rows?
      search('/RETS/MAXROWS').length > 0
    end
    def to_transaction
      transaction = Client::Transaction.new
      transaction.reply_code = reply_code.to_s
      transaction.reply_text = reply_text
      transaction.maxrows    = max_rows?
      transaction.response = yield self if block_given?
      transaction
    end
    def error?
      reply_code > 0 && reply_code != 20201
    end
    def valid?
      !blank? && rets? && !error?
    end
    def invalid?
      !valid?
    end
    def validate!
    # TODO: write a validate that's consistant with the one in nokogiri
      raise Client::RETSException, 'No transaction body was returned.' if blank?

      raise Client::RETSException, "Response had invalid root node. Document was: #{inspect}" unless rets?

      if error?
        exception_type = Client::EXCEPTION_TYPES[reply_code] || Client::RETSTransactionException
        raise exception_type, "#{reply_code} - #{reply_text}"
      end
    end
    # def parse_results
    #   transaction = Transaction.new
    #   transaction
    # end
  end
end
