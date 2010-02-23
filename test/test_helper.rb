$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'test/unit'
require 'rets4r'
require 'rubygems'
require 'shoulda'
require 'mocha'

# Configure ListingService
listing_service_config_file = File.expand_path(File.join('test', 'data', 'listing_service.yml'))
RETS4R::ListingService.configurations = YAML.load_file(listing_service_config_file)
RETS4R::ListingService.env = 'test'
