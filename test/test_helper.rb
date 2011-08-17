libdir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'test/unit'
require 'mocha'
require 'shoulda'
require 'pathname'

unless defined? PROJECT_ROOT
  PROJECT_ROOT = Pathname(__FILE__).join('../..').expand_path
  support_dir = PROJECT_ROOT.join('test', "support")
  $LOAD_PATH.unshift(support_dir)
  Pathname(support_dir).children.each do |file|
    require file
  end
end

class Test::Unit::TestCase
  def fixture(*path_elems)
    PROJECT_ROOT.join('test', 'data', '1.5', *path_elems)
  end
end
