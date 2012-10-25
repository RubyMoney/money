$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rspec'
require 'money'
require 'support/default_currency_helper'

RSpec.configure do |c|
  c.order = "rand"
  c.include DefaultCurrencyHelper
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
