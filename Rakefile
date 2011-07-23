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

task :default => %w{test test:isolated}

namespace :test do
  Rake::TestTask.new(:isolated) do |t|
    t.pattern = 'test/ts_isolated.rb'
  end
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rets4r #{version}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
CLEAN << 'rdoc'

file 'MANIFEST.tmp' do
  sh %{git ls-files > MANIFEST.tmp}
end
CLEAN << 'MANIFEST.tmp'

desc "Check the manifest against current files"
task :check_manifest => [:clean, 'MANIFEST', 'MANIFEST.tmp'] do
  puts `diff -du MANIFEST MANIFEST.tmp`
end

CLEAN << '.rake_tasks'

Bundler::GemHelper.install_tasks
CLEAN << 'pkg/*'
CLOBBER << 'Gemfile.lock'
CLOBBER << "rets4r-#{RETS4R::VERSION}.gem"
