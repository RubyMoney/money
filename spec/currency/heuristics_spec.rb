# frozen_string_literal: true

RSpec.describe Money::Currency::Heuristics do
  describe "#analyze_string" do
    it "raises deprecation error" do
      expect { Money::Currency.analyze('123') }.to raise_error(StandardError, 'Heuristics deprecated, add `gem "money-heuristics"` to Gemfile')
    end
  end
end
