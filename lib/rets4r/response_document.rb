require 'rets4r/client/transaction'
require 'rets4r/client/exceptions'

module RETS4R
  class ResponseDocument < Nokogiri::XML::Document
    def self.safe_parse(*args)
      parse(*args) do |config|
        config.strict.noblanks
        config.strict.noerror
        config.strict.recover
      end
    end

    def rets?
      root && root.name == 'RETS'
    end

    def reply_code
      root['ReplyCode'].to_i
    end

    def success?
      reply_code == 0
    end

    def reply_text
      root['ReplyText']
    end

    def max_rows?
      search('/RETS/MAXROWS').length > 0
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

    # raises exceptions if things are wrong. returns self, so you can chain this
    def validate!
    # TODO: write a validate that's consistant with the one in nokogiri
      raise Client::RETSException, 'No transaction body was returned.' if blank?

      raise Client::RETSException, "Response had invalid root node. Document was: #{inspect}" unless rets?

      if error?
        exception_type = Client::EXCEPTION_TYPES[reply_code] || Client::RETSTransactionException
        raise exception_type, "#{reply_code} - #{reply_text}"
      end
      self
    end

    def count
      self.at('/RETS/COUNT')['Records'].to_i
    end

    def to_rexml
      REXML::Document.new(to_s)
    end

    def to_h
      pairs = first_child.text.map do |line|
        key, value = parse_key_value_line(line)
      end
      Hash[pairs]
    end

    def parse_count
      to_transaction { count }
    end

    def parse_results
      to_transaction do
        RETS4R::Client::CompactDataParser.new.parse_results(self)
      end
    end

    def parse_key_value
      to_transaction { to_h }
    end

    def to_transaction
      Client::Transaction.new.tap do |t|
        t.reply_code = reply_code.to_s
        t.reply_text = reply_text
        t.maxrows = max_rows?
        t.response = yield if block_given?
      end
    end

    private
    def first_child
      self.at('/RETS/RETS-RESPONSE') or self.at('/RETS')
    end
    def parse_key_value_line(line)
      (key, value) = line.strip.split('=')
      key.strip! if key
      value.strip! if value
      [key, value]
    end
  end
end
