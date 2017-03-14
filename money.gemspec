# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "money/version"

Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = Money::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = ["shane@emmons.io"]
  s.homepage    = "https://rubymoney.github.io/money"
  s.summary     = "A Ruby Library for dealing with money and currency conversion."
  s.description = "A Ruby Library for dealing with money and currency conversion."
  s.license     = "MIT"

  s.add_dependency 'i18n', ['>= 0.6.4', '< 0.9']

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.4.0"
  s.add_development_dependency "yard", "~> 0.8"
  s.add_development_dependency "kramdown", "~> 1.1"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
end
