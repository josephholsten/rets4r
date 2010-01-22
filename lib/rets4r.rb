# Add lib/rets4r as a default load path.
dir = File.join File.dirname(__FILE__), 'rets4r'
$:.unshift(dir) unless $:.include?(dir) || $:.include?(File.expand_path(dir))

require 'client'
require 'loader'
