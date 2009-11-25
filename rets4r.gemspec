# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rets4r}
  s.version = "1.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Patterson", "John Wulff", "bgetting", "Jacob Basham"]
  s.date = %q{2009-11-25}
  s.email = ["scott.patterson@digitalaun.com", "john@johnwulff.com", "brian@terra-firma-design.com", "jacob@paperpigeons.net"]
  s.extra_rdoc_files = [
    "CHANGELOG",
     "CONTRIBUTORS",
     "GPL",
     "LICENSE",
     "README.rdoc",
     "RUBYS",
     "TODO"
  ]
  s.files = [
    "CHANGELOG",
     "CONTRIBUTORS",
     "GPL",
     "LICENSE",
     "README.rdoc",
     "RUBYS",
     "Rakefile",
     "TODO",
     "VERSION.yml",
     "examples/client_get_object.rb",
     "examples/client_login.rb",
     "examples/client_metadata.rb",
     "examples/client_search.rb",
     "examples/settings.yml",
     "lib/rets4r.rb",
     "lib/rets4r/auth.rb",
     "lib/rets4r/client.rb",
     "lib/rets4r/client/data.rb",
     "lib/rets4r/client/dataobject.rb",
     "lib/rets4r/client/metadata.rb",
     "lib/rets4r/client/metadataindex.rb",
     "lib/rets4r/client/parsers/compact.rb",
     "lib/rets4r/client/parsers/metadata.rb",
     "lib/rets4r/client/parsers/response_parser.rb",
     "lib/rets4r/client/transaction.rb",
     "lib/tasks/annotations.rake",
     "lib/tasks/coverage.rake",
     "test/data/1.5/error.xml",
     "test/data/1.5/invalid_compact.xml",
     "test/data/1.5/login.xml",
     "test/data/1.5/metadata.xml",
     "test/data/1.5/search_compact.xml",
     "test/data/1.5/search_unescaped_compact.xml",
     "test/test_auth.rb",
     "test/test_client.rb",
     "test/test_metadataindex.rb",
     "test/test_parser.rb"
  ]
  s.homepage = %q{http://rets4r.rubyforge.org/}
  s.rdoc_options = ["--charset=UTF-8", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rets4r}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A native Ruby implementation of RETS (Real Estate Transaction Standard).}
  s.test_files = [
    "test/test_auth.rb",
     "test/test_client.rb",
     "test/test_metadataindex.rb",
     "test/test_parser.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

