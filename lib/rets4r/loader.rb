module RETS4R
  # Loader is a convenience class to get lightning-fast RETS XML Document
  # parsing without a lot of typing. Just hand ::load an IO to read the XML
  # from and a block to handle each record. You'll get the work done really
  # fast without thrashing your memory like conventional DOM parsers like to do.
  class Loader
    def self.load(io, &block)
      parser = RETS4R::Client::CompactNokogiriParser.new(io)
      parser.each(&block)
    end
  end
end
