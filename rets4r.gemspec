lib     = File.expand_path("../lib/rets4r.rb", __FILE__)
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d+)\1/, 2]

Gem::Specification.new do |spec|
  spec.name = 'rets4r'
  spec.authors = ["Scott Patterson", "John Wulff", "bgetting", "Jacob Basham", "Joseph Holsten", "Braxton Beyer"]
  spec.email = ["scott.patterson@digitalaun.com", "john@johnwulff.com", "brian@terra-firma-design.com", "jacob@paperpigeons.net", "joseph@josephholsten.com", "braxton@braxtonbeyer.com"]
  spec.homepage = 'http://rets4r.rubyforge.org/'
  spec.rubyforge_project = 'rets4r'
  spec.description = %q{RETS4R is a native Ruby interface to the RETS (Real Estate Transaction Standard). It currently is built for the 1.5 specification, but support for 1.7 and 2.0 are planned. It does not currently implement all of the specification, but the most commonly used portions. Specifically, there is no support for Update transactions.}
  spec.extra_rdoc_files = %w[CHANGELOG CONTRIBUTORS LICENSE MANIFEST NEWS README.rdoc RUBYS TODO ]
  spec.rdoc_options << "--charset=UTF-8" <<
                       "--main" << "README.rdoc"
  spec.version = version
  spec.summary = spec.description.split(/\.\s+/).first
  spec.files = File.read("MANIFEST").split(/\r?\n\r?/)

  spec.add_runtime_dependency 'nokogiri', '>= 1.3.2'
  spec.add_runtime_dependency 'activesupport', '>= 2.3.2'
  spec.add_development_dependency 'i18n'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'shoulda'
end

