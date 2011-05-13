#!/usr/bin/env ruby
#
# This is an example of how to use the RETS client to log in and out of a server.
#
# You will need to set the necessary variables below.
#
#############################################################################################

$:.unshift 'lib'
require 'active_support/core_ext/hash'
require 'logger'
require 'yaml'

require 'rets4r'

# Settings
settings_file = File.expand_path(File.join(File.dirname(__FILE__), "settings.yml"))
env = ENV['LISTING_ENV'] || 'development'
settings = YAML.load_file(settings_file)[env].symbolize_keys

#############################################################################################

client = RETS4R::Client.new(settings[:url])
client.logger = Logger.new(STDOUT)

login_result = client.login(settings[:username], settings[:password])

if login_result.success?
    puts "We successfully logged into the RETS server!"

    # Print the action URL results (if any)
    puts login_result.secondary_response

    client.logout

    puts "We just logged out of the server."
else
    puts "We were unable to log into the RETS server."
    puts "Please check that you have set the login variables correctly."
end
