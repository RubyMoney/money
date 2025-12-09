# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
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

  s.add_dependency "bigdecimal"
  s.add_dependency "i18n", "~> 1.9"

  s.required_ruby_version = ">= 3.1"

  s.files         = `git ls-files -z -- config/* lib/* CHANGELOG.md LICENSE money.gemspec README.md`.split("\x0")
  s.require_paths = ["lib"]

  if s.respond_to?(:metadata)
    s.metadata['changelog_uri'] = 'https://github.com/RubyMoney/money/blob/main/CHANGELOG.md'
    s.metadata['source_code_uri'] = 'https://github.com/RubyMoney/money/'
    s.metadata['bug_tracker_uri'] = 'https://github.com/RubyMoney/money/issues'
    s.metadata['rubygems_mfa_required'] = 'true'
  end
end
