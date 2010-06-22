#!/usr/bin/env ruby
#
# This is an example of how to use the RETS client to perform a basic search.
#
# You will need to set the necessary variables below.
#
#############################################################################################
# Settings

require 'yaml'
require 'active_support/core_ext/hash'
settings_file = File.expand_path(File.join(File.dirname(__FILE__), "settings.yml"))
ENV['LISTING_ENV'] ||= 'development'
settings = YAML.load_file(settings_file)[ENV['LISTING_ENV']].symbolize_keys

#############################################################################################
$:.unshift 'lib'

require 'rets4r'

client = RETS4R::Client.new(settings[:url])

logger = Logger.new($stdout)
logger.level = Logger::WARN
client.logger = logger

login_result = client.login(settings[:username], settings[:password])

if login_result.success?
    puts "We successfully logged into the RETS server!"

    options = {'Limit' => settings[:limit]}

    client.search(settings[:resource], settings[:class], settings[:query], options) do |result|
        result.response.each do |row|
            puts row.inspect
            puts
        end
    end

    client.logout

    puts "We just logged out of the server."
else
    puts "We were unable to log into the RETS server."
    puts "Please check that you have set the login variables correctly."
end

logger.close
