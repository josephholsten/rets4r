# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rets4r}
  s.version = "0.0.0"

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
     "lib/rets4r.rb",
     "test/rets4r_test.rb",
     "test/test_helper.rb"
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
