require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.dirname(__FILE__)
require "rspec"
require "money"

I18n.enforce_available_locales = false

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end

RSpec.shared_context "with infinite precision", :infinite_precision do
  before do
    Money.infinite_precision = true
  end

  after do
    Money.infinite_precision = false
  end
end
