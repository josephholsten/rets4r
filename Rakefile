require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils

# impart all tasks in lib/tasks/
Dir['lib/tasks/*.rake'].each { |task| import task }

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
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
  sh %{find . -type f | sed 's/\\.\\///' | grep -v '.git' | sort > MANIFEST.tmp}
end
CLEAN << 'MANIFEST.tmp'

desc "Check the manifest against current files"
task :check_manifest => [:clean, 'MANIFEST', 'MANIFEST.tmp'] do
  puts `diff -du MANIFEST MANIFEST.tmp`
end

CLEAN << '.rake_tasks'

lib     = File.expand_path("../lib/rets4r.rb", __FILE__)
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d+)\1/, 2]
CLEAN << "rets4r-#{version}.gem"
