source 'https://rubygems.org'

gem 'coveralls', '>= 0.8.17', :require => false
gem 'pry', :require => false

# JSON gem no longer supports ruby < 2.0.0
if defined?(JRUBY_VERSION)
  gem 'json'
elsif RUBY_VERSION =~ /^1/
  # Legacy gem locks for ruby 1.9.x
  gem 'json',           '~> 1.8.3'
  gem 'tins',           '~> 1.6.0'
  gem 'term-ansicolor', '< 1.4'
end

gemspec
