require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'

module RETS4R
  class ListingService
    # RECORD_COUNT_ONLY=Librets::SearchRequest::RECORD_COUNT_ONLY
    RECORD_COUNT_ONLY='fixme'
    # Contains the listing service configurations - typically stored in
    # config/listing_service.yml - as a Hash.
    cattr_accessor :configurations, :instance_writer => false
    cattr_accessor :env, :instance_writer => false

    class << self

      # Connection configuration for the specified environment, or the current
      # environment if none is given.
      def connection(spec = nil)
        case spec
          when nil
            connection(RETS4R::ListingService.env)
          when Symbol, String
            if configuration = configurations[spec.to_s]
              configuration.symbolize_keys
            else
              raise ArgumentError, "#{spec} listing service is not configured"
            end
          else
            raise ArgumentError, "#{spec} listing service is not configured"
        end
      end

    end # class << self
  end
end