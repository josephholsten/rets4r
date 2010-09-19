require 'rubygems'

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rets4r"
    gem.description = %q{RETS4R is a native Ruby interface to the RETS (Real Estate Transaction Standard). It currently is built for the 1.5 specification, but support for 1.7 and 2.0 are planned. It does not currently implement all of the specification, but the most commonly used portions. Specifically, there is no support for Update transactions.}
    gem.email = ["scott.patterson@digitalaun.com", "john@johnwulff.com",
                 "brian@terra-firma-design.com", "jacob@paperpigeons.net",
                 "joseph@josephholsten.com"]
    gem.summary = gem.description.split(/\.\s+/).first
    gem.homepage = 'http://rets4r.rubyforge.org/'
    gem.rubyforge_project = 'rets4r'
    gem.authors = ["Scott Patterson", "John Wulff", "begetting", "Jacob Basham", "Joseph Holsten"]
    gem.extra_rdoc_files = %w[CHANGELOG CONTRIBUTORS LICENSE MANIFEST NEWS README.rdoc RUBYS TODO ]
    gem.rdoc_options << "--charset=UTF-8" << "--main" << "README.rdoc"
    gem.add_runtime_dependency 'nokogiri', '~>1.4.0'
    gem.add_development_dependency "shoulda"
    gem.add_development_dependency "mocha"
    gem.add_development_dependency "activesupport"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rets4r #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# +++++++++++++++++++++++++++++++++++++++++++++++++++++

# require 'rake'
# require 'rake/clean'
# require 'rake/packagetask'
# require 'rake/gempackagetask'
# require 'rake/contrib/rubyforgepublisher'
# require 'fileutils'
# include FileUtils

# # impart all tasks in lib/tasks/
# Dir['lib/tasks/*.rake'].each { |task| import task }

# require 'rake/testtask'
# Rake::TestTask.new(:test) do |test|
#   test.verbose = true
# end

# task :default => :test

# require 'rake/rdoctask'
# Rake::RDocTask.new do |rdoc|
#   if File.exist?('VERSION.yml')
#     config = YAML.load(File.read('VERSION.yml'))
#     version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
#   else
#     version = ""
#   end

#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = "rets4r #{version}"
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README.rdoc')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
# CLEAN << 'rdoc'

# file 'MANIFEST.tmp' do
#   sh %{find . -type f | sed 's/\\.\\///' | grep -v '.git' | sort > MANIFEST.tmp}
# end
# CLEAN << 'MANIFEST.tmp'

# desc "Check the manifest against current files"
# task :check_manifest => [:clean, 'MANIFEST', 'MANIFEST.tmp'] do
#   puts `diff -du MANIFEST MANIFEST.tmp`
# end

# CLEAN << '.rake_tasks'

# lib     = File.expand_path("../lib/rets4r.rb", __FILE__)
# version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d+)\1/, 2]
# CLEAN << "rets4r-#{version}.gem"
