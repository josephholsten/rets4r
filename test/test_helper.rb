libdir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'test/unit'
require 'mocha'
require 'shoulda'
require 'pathname'

unless defined? PROJECT_ROOT
  PROJECT_ROOT = Pathname(__FILE__).join('../..')
  support_dir = File.join(File.expand_path(File.dirname(__FILE__)), "support")
  $LOAD_PATH.unshift(support_dir)
  Pathname(support_dir).children.each do |file|
    require file
  end
end
