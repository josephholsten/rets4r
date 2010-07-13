module RETS4R
  class Loader
    def self.load(io, &block)
      parser = RETS4R::Client::CompactNokogiriParser.new(io)
      parser.each(&block)
    end
  end
end
