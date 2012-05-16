# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = "5.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin",
                   "Shane Emmons", "Simone Carletti"]
  s.email       = ["semmons99+RubyMoney@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/money"
  s.summary     = "Money and currency exchange support library."
  s.description = "This library aids one in handling money and different currencies."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "i18n",       "~> 0.6.0"
  s.add_dependency "multi_json", "~> 1.3.5"

  s.add_development_dependency "rspec",       "~> 2.10.0"
  s.add_development_dependency "yard",        "~> 0.8.1"
  s.add_development_dependency "redcarpet",   "~> 2.1.1"
  s.add_development_dependency "guard",       "~> 1.0.2"
  s.add_development_dependency "spork",       "~> 0.9.0"
  s.add_development_dependency "guard-spork", "~> 0.8.0"
  s.add_development_dependency "guard-rspec", "~> 0.7.2"

  s.files =  Dir.glob("{config,lib,spec}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile .gemtest money.gemspec)

  s.require_path = "lib"
end
