module RETS4R
  class Loader
    def self.load(file, &block)
      parser = RETS4R::Client::CompactNokogiriParser.new(file)
      parser.each(&block)
    end
  end
end
