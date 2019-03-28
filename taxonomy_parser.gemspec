# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taxonomy_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "taxonomy_parser"
  spec.version       = TaxonomyParser::VERSION
  spec.authors       = ["Tim Hammer"]
  spec.email         = ["timh@govwizely.com"]
  spec.summary       = "A gem for parsing the ITA Taxonomy's XML from Webprotege."
  spec.homepage      = "https://github.com/GovWizely/taxonomy_parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject{|file| file.include?(".gem")}
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "12.3.1"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "nokogiri", ">= 1.8.5"
  spec.add_dependency "rubyzip", "1.2.2"
  spec.add_dependency "iso_country_codes", "0.7.8"
  spec.add_development_dependency "webmock"
  spec.add_dependency 'codeclimate-test-reporter'
end
