# frozen_string_literal: true

RSpec.shared_context "with infinite precision", :default_infinite_precision_true do
  before do
    Money.default_infinite_precision = true
  end

  after do
    Money.default_infinite_precision = false
  end
end
