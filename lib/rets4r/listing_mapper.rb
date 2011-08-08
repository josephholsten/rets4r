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
    def to_dmql(listing_attributes)
      reverse_map(listing_attributes).map do |k,v|
        %[(#{k.to_sym}=#{field_encode_value(v)})]
      end.join(',')
    end
    def reverse_map(listing_attributes)
      select.inject({}) do |hash,(k,v)|
        hash.tap { |h| h[k] = listing_attributes[v] if listing_attributes[v] }
      end
    end
    private
    def field_encode_value(v)
      if v.to_s =~ /^\d+$/
        v
      else
        %["#{v}"]
      end
    end
  end
end
