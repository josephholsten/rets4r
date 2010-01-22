module RETS4R
  class Loader
    def self.load(file)
      parser = RETS4R::Client::CompactNokogiriParser.new
      listings = parser.parse_results(file)

      listings.each {|original|
        yield original
      }
    end
  end
end