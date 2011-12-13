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


def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end

def store_number_currency_formats(locale)
  I18n.backend.store_translations(locale,
                                  :number => {
                                      :currency => {
                                          :format => {
                                              :delimiter => ",",
                                              :separator => "."
                                          }
                                      }
                                  })
end
