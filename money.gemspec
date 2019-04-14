# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "money/version"

Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = Money::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Shane Emmons', 'Anthony Dmitriyev']
  s.email       = ['shane@emmons.io', 'anthony.dmitriyev@gmail.com']
  s.homepage    = "https://rubymoney.github.io/money"
  s.summary     = "A Ruby Library for dealing with money and currency conversion."
  s.description = "A Ruby Library for dealing with money and currency conversion."
  s.license     = "MIT"

  s.add_dependency 'i18n', [">= 0.6.4", '<= 2']

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "yard", "~> 0.9.11"
  s.add_development_dependency "kramdown", "~> 1.1"

  s.files         = `git ls-files -z -- config/* lib/* CHANGELOG.md LICENSE money.gemspec README.md`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  if s.respond_to?(:metadata)
    s.metadata['changelog_uri'] = 'https://github.com/RubyMoney/money/blob/master/CHANGELOG.md'
    s.metadata['source_code_uri'] = 'https://github.com/RubyMoney/money/'
    s.metadata['bug_tracker_uri'] = 'https://github.com/RubyMoney/money/issues'
  end
end
