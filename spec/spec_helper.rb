require 'rspec'
require 'money'

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.expand_path("../", __FILE__)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(SPEC_ROOT, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
end


# Sets $VERBOSE to nil for the duration of the block and back to its original value afterwards.
#
#   silence_warnings do
#     value = noisy_call # no warning voiced
#   end
#
#   noisy_call # warning voiced
def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end
