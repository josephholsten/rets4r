module RETS4R
  class Loader
    def self.load(file)
      file = open(file) unless file.respond_to? :read
      # parse
      parser = RETS4R::Client::ResponseParser.new
      transaction = parser.parse_results(file, 'COMPACT')
      listings = transaction.response

      listings.each {|original|
        yield original
      }
    end
  end
end