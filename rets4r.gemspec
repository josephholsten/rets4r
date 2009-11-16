require 'rubygems'

Gem::Specification.new do |s|
    s.name = %q{rets4r}
    s.version = "1.1.2"

    s.authors = ["Scott Patterson", "John Wulff", "bgetting"]
    s.date = %q{2009-08-02}
    s.email = ["scott.patterson@digitalaun.com", "john@johnwulff.com", "brian@terra-firma-design.com"]
    s.has_rdoc = true
    s.extra_rdoc_files = [
      'CHANGELOG',
      'CONTRIBUTORS',
      'GPL',
      'LICENSE',
      'README',
      'RUBYS',
      'TODO'
    ]
    s.files = [
      'CHANGELOG',
      'CONTRIBUTORS',
      'GPL',
      'LICENSE',
      'README',
      'RUBYS',
      "Rakefile",
      'TODO'
      "VERSION.yml",
      "examples/client_get_object.rb",
      "examples/client_login.rb",
      "examples/client_metadata.rb",
      "examples/client_search.rb",
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
      "test/tc_auth.rb",
      "test/tc_client.rb",
      "test/tc_metadataindex.rb",
      "test/test_parser.rb",
      "test/ts_all.rb",
    ]
    s.homepage = %q{http://rets4r.rubyforge.org/}
    s.rdoc_options = ["--charset=UTF-8", '--main' , 'README']
    s.require_paths = ["lib"]
    s.rubyforge_project = %q{rets4r}
    s.summary = %q{A native Ruby implementation of RETS (Real Estate Transaction Standard).}
    s.test_files = [
      "test/ts_all.rb",
    ]
end
