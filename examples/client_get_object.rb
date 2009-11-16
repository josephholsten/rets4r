#!/usr/bin/ruby
#
# This is an example of how to use the RETS client to retrieve an objet.
#
# You will need to set the necessary variables below.
#
#############################################################################################
# Settings

require 'yaml'
settings_file = File.expand_path(File.join(File.dirname(__FILE__), "settings.yml"))
settings = YAML.load_file(settings_file)['settings']

#############################################################################################
$:.unshift 'lib'

require 'rets4r'
require 'logger'

def handle_object(object)
    case object.info['Content-Type']
        when 'image/jpeg' then extension = 'jpg'
        when 'image/gif'  then extension = 'gif'
        when 'image/png'  then extension = 'png'
        else extension = 'unknown'
    end

    File.open("#{object.info['Content-ID']}_#{object.info['Object-ID']}.#{extension}", 'w') do |f|
        f.write(object.data)
    end
end

client = RETS4R::Client.new(settings[:url])

client.login(settings[:username], settings[:password]) do |login_result|

    if login_result.success?
        ## Method 1
        # Get objects using a block
        client.get_object(settings[:resource], settings[:object_type], settings[:resource_id]) do |object|
            handle_object(object)
        end
    else
        puts "We were unable to log into the RETS server."
        puts "Please check that you have set the login variables correctly."
    end
end
