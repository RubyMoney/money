# frozen_string_literal: true

describe Money::Bank::SingleCurrency do
  describe "#exchange_with" do
    it "raises when called" do
      expect {
        subject.exchange_with(Money.new(100, 'USD'), 'EUR')
      }.to raise_error(Money::Bank::DifferentCurrencyError, "No exchanging of currencies allowed: 1.00 USD to EUR")
    end
  end
end
