require 'rspec'
require 'money'

RSpec.configure do |c|
  c.order = "rand"
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
