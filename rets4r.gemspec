# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rets4r}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["bgetting"]
  s.date = %q{2009-08-02}
  s.email = %q{brian@terra-firma-design.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "examples/client_get_object.rb",
     "examples/client_login.rb",
     "examples/client_metadata.rb",
     "examples/client_search.rb",
     "examples/metadata.xml",
     "lib/rets4r.rb",
     "lib/rets4r/auth.rb",
     "lib/rets4r/client.rb",
     "lib/rets4r/client/data.rb",
     "lib/rets4r/client/dataobject.rb",
     "lib/rets4r/client/metadata.rb",
     "lib/rets4r/client/metadataindex.rb",
     "lib/rets4r/client/parser.rb",
     "lib/rets4r/client/parser/rexml.rb",
     "lib/rets4r/client/parser/xmlparser.rb",
     "lib/rets4r/client/transaction.rb",
     "rets4r.gemspec",
     "test/client/data/1.5/error.xml",
     "test/client/data/1.5/invalid_compact.xml",
     "test/client/data/1.5/login.xml",
     "test/client/data/1.5/metadata.xml",
     "test/client/data/1.5/search_compact.xml",
     "test/client/data/1.5/search_unescaped_compact.xml",
     "test/client/parser/tc_rexml.rb",
     "test/client/parser/tc_xmlparser.rb",
     "test/client/tc_auth.rb",
     "test/client/tc_client.rb",
     "test/client/tc_metadataindex.rb",
     "test/client/test_parser.rb",
     "test/client/ts_all.rb",
     "test/rets4r_test.rb",
     "test/test_helper.rb",
     "test/ts_all.rb",
     "test/ts_client.rb"
  ]
  s.homepage = %q{http://github.com/bgetting/rets4r}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{TODO}
  s.test_files = [
    "test/client/parser/tc_rexml.rb",
     "test/client/parser/tc_xmlparser.rb",
     "test/client/tc_auth.rb",
     "test/client/tc_client.rb",
     "test/client/tc_metadataindex.rb",
     "test/client/test_parser.rb",
     "test/client/ts_all.rb",
     "test/rets4r_test.rb",
     "test/test_helper.rb",
     "test/ts_all.rb",
     "test/ts_client.rb",
     "examples/client_get_object.rb",
     "examples/client_login.rb",
     "examples/client_metadata.rb",
     "examples/client_search.rb"
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
