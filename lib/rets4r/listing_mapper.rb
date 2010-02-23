module RETS4R
  class ListingMapper
    def initialize(params = {})
      @select = params[:select] || ListingService.connection[:select]
    end
    def select
      @select
    end
    def map(original)
      listing = {}
      @select.each_pair {|rets_key, record_key|
        listing[record_key] = original[rets_key]
      }
      listing
    end
  end
end
