source "https://rubygems.org"

gem "coveralls", :require => false
gem "pry", :require => false

# JSON gem no longer supports ruby < 2.0.0
if defined?(JRUBY_VERSION)
  gem "json"
elsif RUBY_VERSION =~ /^1/
  gem "json", "~> 1.8.3"
end

gemspec
