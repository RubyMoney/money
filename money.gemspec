# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = "6.0.0.pre5"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin",
                   "Shane Emmons", "Simone Carletti"]
  s.email       = ["semmons99+RubyMoney@gmail.com"]
  s.homepage    = "http://rubymoney.github.com/money"
  s.summary     = "Money and currency exchange support library."
  s.description = "This library aids one in handling money and different currencies."

  s.post_install_message = '''
Please note the following API changes in Money version 6

 - Money#amount, Money#dollars methods now return instances of BigDecimal (rather than Float).

Please read the migration notes at https://github.com/RubyMoney/money#migration-notes
and choose the migration that best suits your application.

Test responsibly :-)
'''

  s.required_ruby_version     = ">= 1.8.7"

  s.add_dependency "i18n",       "~> 0.6.4"

  s.add_development_dependency "rspec",       "~> 2.14"
  s.add_development_dependency "yard",        "~> 0.8"
  s.add_development_dependency "kramdown",    "~> 1.1"

  s.license = "MIT"

  s.files =  Dir.glob("{config,lib,spec}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile money.gemspec)

  s.require_path = "lib"
end
