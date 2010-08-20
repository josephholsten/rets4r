#!/usr/bin/env ruby
#
# This is an example of how to use the RETS client to login to a server and retrieve metadata. It
# also makes use of passing blocks to client methods and demonstrates how to set the output format.
#
# You will need to set the necessary variables below.
#
#############################################################################################
# Settings

require 'yaml'
require 'active_support/core_ext/hash'
settings_file = File.expand_path(File.join(File.dirname(__FILE__), "settings.yml"))
env = ENV['LISTING_ENV'] || 'development'
settings = YAML.load_file(settings_file)[env].symbolize_keys

#############################################################################################
$:.unshift 'lib'

require 'rets4r'

RETS4R::Client.new(settings[:url]) do |client|
    client.login(settings[:username], settings[:password]) do |login_result|
        if login_result.success?
            puts "Logged in successfully!"

            metadata = ''

            begin
                metadata = client.get_metadata(*ARGV)
            rescue
                puts "Unable to get metadata: '#{$!}'"
            end

            File.open('metadata.xml', 'w') do |file|
                file.write metadata
            end
        else
            puts "Unable to login: '#{login_result.reply_text}'."
        end
    end
end
