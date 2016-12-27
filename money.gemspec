# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'money/version'

Gem::Specification.new do |s|
  s.name        = 'money2'
  s.version     = Money::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Shane Emmons']
  s.email       = ['shane@emmons.io']
  s.homepage    = 'http://rubymoney.github.io/money'
  s.summary     = 'A Ruby Library for dealing with money and currency conversion.'
  s.description = 'A Ruby Library for dealing with money and currency conversion.'
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'i18n', ['>= 0.6.4', '<= 0.7.0']

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'rspec-its', '~> 1.1.0'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'kramdown', '~> 1.1'
  s.add_development_dependency 'sixarm_ruby_unaccent', ['>= 1.1.1', '< 2']
end
