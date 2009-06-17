# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rets4r}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Wulff", "Jacob Basham"]
  s.date = %q{2009-056-16}
  s.email = %q{jacob@paperpigeons.net}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = [
		"README.rdoc", 
		"VERSION.yml", 
		"lib/rets4r", 
		"lib/rets4r/auth.rb", 
		"lib/rets4r/client", 
		"lib/rets4r/client/data.rb", 
		"lib/rets4r/client/dataobject.rb", 
		"lib/rets4r/client/metadata.rb", 
		"lib/rets4r/client/metadataindex.rb", 
		"lib/rets4r/client/parser.rb", 
		"lib/rets4r/client/parsers", 
		"lib/rets4r/client/parsers/compact.rb", 
		"lib/rets4r/client/parsers/metadata.rb", 
		"lib/rets4r/client/parsers/response_parser.rb", 
		"lib/rets4r/client/transaction.rb", 
		"lib/rets4r/client.rb", 
		"lib/rets4r.rb", 
		"spec/rets4r_spec.rb", 
		"spec/spec_helper.rb", 
		"LICENSE"
	]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jkestr/rets4r}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Pure Ruby RETS client}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
