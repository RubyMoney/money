require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.dirname(__FILE__)
require "rspec"
require "money"

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

I18n.enforce_available_locales = false

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end

RSpec.shared_context  "with infinite precision set as default",
                      :default_infinite_precision_true do
  before do
    @previous_infinite_precision = Money.default_infinite_precision
    Money.default_infinite_precision = true
  end

  after do
    Money.default_infinite_precision = @previous_infinite_precision
  end
end

RSpec.shared_context  "with infinite precision not set as default",
                      :default_infinite_precision_false do
  before do
    @previous_infinite_precision = Money.default_infinite_precision
    Money.default_infinite_precision = false
  end

  after do
    Money.default_infinite_precision = @previous_infinite_precision
  end
end
