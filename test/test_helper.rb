libdir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'test/unit'
require 'mocha'
require 'shoulda'
require 'pathname'

unless defined? PROJECT_ROOT
  PROJECT_ROOT = Pathname(__FILE__).join('../..')
  PROJECT_ROOT.join('test/support').children.each {|f| require f}
end
