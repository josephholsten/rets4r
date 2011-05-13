#!/usr/bin/env ruby
$:.unshift 'lib'
require 'yaml'

require 'rets4r'

listing_service_config_file = File.expand_path(File.join(File.dirname(__FILE__), "settings.yml"))
RETS4R::ListingService.configurations = YAML.load_file(listing_service_config_file)
RETS4R::ListingService.env = ENV['RETS4RENV'] || 'development'

xml = ARGF

mapper = RETS4R::ListingMapper.new
RETS4R::Loader.load(xml) do |record|
  attributes = mapper.map(record)
  puts attributes.inspect
end
