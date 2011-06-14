# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = "3.7.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin",
                   "Shane Emmons", "Simone Carletti", "Jean-Louis Giordano",
                   "Joshua Clayton", "Bodaniel Jeanes", "Tobias Schmidt",
                   "Chris Kampmeier", "Romain Gérard", "Eloy", "Josh Delsman",
                   "Pelle Braendgaard", "Tom Lianza", "James Cotterill",
                   "François Beausoleil", "Abhay Kumar", "pconnor",
                   "Christian Billen", "Ilia Lobsanov", "Andrew White",
                  ]
  s.email       = ["hongli@phusion.nl", "semmons99+RubyMoney@gmail.com"]
  s.homepage    = "http://money.rubyforge.org"
  s.summary     = "Money and currency exchange support library."
  s.description = "This library aids one in handling money and different currencies."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "money"

  s.add_dependency "i18n", "~> 0.4"

  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "yard"
  s.add_development_dependency "json"

  s.requirements << "json if you plan to import/export rates formatted as json"

  s.files =  Dir.glob("{lib,spec}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile .gemtest money.gemspec)

  s.require_path = "lib"
end
