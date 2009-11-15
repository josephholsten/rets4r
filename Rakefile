require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils

task :default => :test

desc "Run unit tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.test_files = ["test/ts_all.rb"]
  t.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'rets4r'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# begin
#   require 'jeweler'
#   Jeweler::Tasks.new do |gem|
#     gem.name = "rets4r"
#     gem.summary = %Q{TODO}
#     gem.email = "john@johnwulff.com"
#     gem.homepage = "http://github.com/jwulff/rets4r"
#     gem.authors = ["John Wulff"]
#     # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
#   end
# rescue LoadError
#   puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
# end
