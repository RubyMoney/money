# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = "5.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin",
                   "Shane Emmons", "Simone Carletti"]
  s.email       = ["semmons99+RubyMoney@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/money"
  s.summary     = "Money and currency exchange support library."
  s.description = "This library aids one in handling money and different currencies."

  s.required_ruby_version     = ">= 1.9.2"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "i18n",       "~> 0.6.0"

  s.add_development_dependency "rspec",       "~> 2.11.0"
  s.add_development_dependency "yard",        "~> 0.8.1"
  s.add_development_dependency "kramdown",    "~> 0.14.0"

  s.files =  Dir.glob("{config,lib,spec}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile money.gemspec)

  s.require_path = "lib"
end
