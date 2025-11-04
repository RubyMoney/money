# frozen_string_literal: true

RSpec.describe Money::Bank::SingleCurrency do
  describe "#exchange_with" do
    it "raises when called" do
      expect do
        subject.exchange_with(Money.new(100, 'USD'), 'EUR')
      end.to raise_error(Money::Bank::DifferentCurrencyError, "No exchanging of currencies allowed: 1.00 USD to EUR")
    end
  end
end
