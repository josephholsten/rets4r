module RETS4R # :nodoc:
  class ListingService
    # Contains the listing service configurations - typically stored in
    # config/listing_service.yml - as a Hash.
    #
    # Most of the time, you'll want to do something like:
    #   # set the current configuration and environment
    #   RETS4R::ListingService.configurations = YAML.load_file('config/listing_service.yml')
    #   RETS4R::ListingService.env = 'production'
    #   # get something useful
    #   url = RETS4R::ListingService.connection[:url]
    unless defined? @@configurations
      @@configurations = nil
    end

    # The configuration hash for every environment that has one.
    def self.configurations
      @@configurations
    end

    # Set the collection of configuration hashes, one for each environment.
    #
    # If you want to set configurations by hand:
    #   RETS4R::ListingService.configurations = {
    #     :development => { 'url' => 'http://www.dis.com:6103/rets/login' }
    #     :test => { 'url' => 'http://demo.crt.realtors.org:6103/rets/login' }
    #   }
    #
    # But you probably just want to do something like this
    #    RETS4R::ListingService.configurations = YAML.load_file('config/listing_service.yml')
    def self.configurations=(obj)
      @@configurations = obj
    end

    unless defined? @@env
      @@env = 'development'
    end

    # Set the current environment to use. Defaults to 'development'.
    def self.env=(obj)
      @@env = obj
    end

    # Current environment used to access the appropriate configuration from
    # ::configurations. Defaults to 'development'.
    def self.env
      @@env
    end

    # Connection configuration for the specified environment, or the current
    # environment if none is given.
    def self.connection(spec = nil)
      case spec
        when nil
          connection(RETS4R::ListingService.env)
        when Symbol, String
          if configuration = configurations[spec.to_s]
            configuration.keys.each do |key|
              configuration[(key.to_sym rescue key) || key] = configuration.delete(key)
            end
            configuration
          else
            raise ArgumentError, "#{spec} listing service is not configured"
          end
        else
          raise ArgumentError, "#{spec} listing service is not configured"
      end
    end
  end
end