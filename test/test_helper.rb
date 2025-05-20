libdir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
$VERBOSE = true

require 'minitest/autorun'
require 'mocha/minitest'
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

class Minitest::Test
  unless method_defined? :fixture
    def fixture(*path_elems)
      PROJECT_ROOT.join('test', 'fixtures', *path_elems)
    end
  end
end
