require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils

# impart all tasks in lib/tasks/
Dir['lib/tasks/*.rake'].each { |task| import task }

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rets4r"
    gem.summary  = 'A native Ruby implementation of RETS (Real Estate Transaction Standard).'
    gem.authors   = ['Scott Patterson', 'John Wulff', 'bgetting', "Jacob Basham"]
    gem.email    = ['scott.patterson@digitalaun.com', 'john@johnwulff.com', 'brian@terra-firma-design.com','jacob@paperpigeons.net']
    gem.homepage = 'http://rets4r.rubyforge.org/'
    gem.files =  FileList["[A-Z]*", "{examples,lib,test}/**/*"]
    gem.rubyforge_project = 'rets4r'
    gem.extra_rdoc_files = ['CONTRIBUTORS', 'README.rdoc', 'LICENSE', 'RUBYS', 'GPL',
      'CHANGELOG', 'TODO' ]
    gem.rdoc_options << '--main' << 'README.rdoc'
    gem.test_files = FileList['test/test_*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << "test"
  test.pattern = ["test/test_*.rb", "test/*_test.rb"]
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
