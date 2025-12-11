# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Money.default_currency = Money::Currency.new("USD")
  end
end
