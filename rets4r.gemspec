require_relative "lib/rets4r/version.rb"
version = RETS4R::VERSION

Gem::Specification.new do |spec|
  spec.name = 'rets4r'
  spec.authors = [
    "Joseph Holsten",
    "Scott Patterson",
    "John Wulff",
    "bgetting",
    "Jacob Basham",
    "Braxton Beyer",
  ]
  spec.email = [
    "joseph@josephholsten.com",
    "scott.patterson@digitalaun.com",
    "john@johnwulff.com",
    "brian@terra-firma-design.com",
    "jacob@paperpigeons.net",
    "braxton@braxtonbeyer.com",
  ]
  spec.homepage = 'https://github.com/josephholsten/rets4r'
  spec.license = 'MIT'
  spec.description = %q{RETS4R is a native Ruby interface to the RETS (Real Estate Transaction Standard). It currently is built for the 1.5 specification, but support for 1.7 and 2.0 are planned. It does not currently implement all of the specification, but the most commonly used portions. Specifically, there is no support for Update transactions.}
  spec.extra_rdoc_files = %w[CHANGELOG CONTRIBUTORS LICENSE.md MANIFEST NEWS README.md TODO]
  spec.rdoc_options << "--charset=UTF-8" <<
                       "--main" << "README.md"
  spec.version = version
  spec.summary = spec.description.split(/\.\s+/).first
  spec.files = File.read("MANIFEST").split(/\r?\n\r?/)

  spec.add_runtime_dependency 'nokogiri', '~> 1.3'
  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_development_dependency 'activesupport', '~> 4.1'
  spec.add_development_dependency 'aruba', '~> 0.6'
  spec.add_development_dependency 'cucumber', '~> 1.3'
  spec.add_development_dependency 'i18n', '~> 0.6'
  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'mocha', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rdoc', '~> 4.1'
  spec.add_development_dependency 'shoulda', '~> 3.5'
end

