require 'rubygems'
require 'spork'

Spork.prefork do
  require 'rspec'

  unless defined?(SPEC_ROOT)
    SPEC_ROOT = File.expand_path("../", __FILE__)
  end

  Dir[File.join(SPEC_ROOT, "support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  def reset_i18n
    I18n.backend = I18n::Backend::Simple.new
  end
end

Spork.each_run do
  require 'money'
end
