# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :default_infinite_precision_true) do
    Money.default_infinite_precision = true
  end

  config.after(:each, :default_infinite_precision_true) do
    Money.default_infinite_precision = false
  end
end
