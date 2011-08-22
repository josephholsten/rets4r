require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/clean'
require 'fileutils'
include FileUtils
require 'rets4r'

# impart all tasks in lib/tasks/
Dir['lib/tasks/*.rake'].each { |task| import task }

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.verbose = true
end
task :default => :test

namespace :test do
  Rake::TestTask.new(:isolated) do |t|
    t.pattern = 'test/ts_isolated.rb'
  end
end
task :default => 'test:isolated'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new
task :default => :cucumber
CLEAN << 'tmp'

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.title = "rets4r #{::RETS4R::VERSION}"
  rdoc.main = 'README.rdoc'
  rdoc.options << '--line-numbers'
end

file 'MANIFEST.tmp' do
  sh %{git ls-files > MANIFEST.tmp}
end
CLEAN << 'MANIFEST.tmp'

namespace :manifest do
  desc "Check the manifest against current files"
  task :diff => [:clean, 'MANIFEST', 'MANIFEST.tmp'] do
    puts `diff -du MANIFEST MANIFEST.tmp`
  end
end

Bundler::GemHelper.install_tasks

CLEAN << '.rake_tasks'
CLEAN << 'pkg/*'
CLOBBER << 'Gemfile.lock'
CLOBBER << "rets4r-#{RETS4R::VERSION}.gem"

task :all => [:default, :rdoc, :build]
