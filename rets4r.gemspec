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
  spec.add_runtime_dependency 'ostruct', '~> 0.6.1'
  spec.add_runtime_dependency 'rexml', '~>3.2'
  spec.add_runtime_dependency 'thor', '~> 1.3'
  spec.add_runtime_dependency 'webrick', '<= 1.8.1' # we depend on flawed header parsing within Auth.parse_header, which is deprecated. Pinning to get one last release, then removing the offending code.

  spec.add_development_dependency 'activesupport', '~> 7.0'
  spec.add_development_dependency 'aruba', '~> 2.3'
  spec.add_development_dependency 'cucumber', '~> 9.2'
  spec.add_development_dependency 'i18n', '~> 1.14'
  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'mocha', '~> 2.7'
  spec.add_development_dependency 'rake', '~>13.2'
  spec.add_development_dependency 'rdoc', '~>6.14'
  spec.add_development_dependency 'shoulda', '~> 4.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'
end

