Gem::Specification.new do |s|
  s.name        = "money"
  s.version     = "3.5.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin", "Shane Emmons", "Simone Carletti"]
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

  s.files        = Dir.glob("lib/**/*") + %w(CHANGELOG.md LICENSE README.md)
  s.require_path = "lib"
end
