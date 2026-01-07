# frozen_string_literal: true

RSpec.describe Money::Bank::SingleCurrency do
  subject(:bank) { described_class.new }

  describe "#exchange_with" do
    it "raises when called" do
      expect do
        bank.exchange_with(Money.new(100, "USD"), "EUR")
      end.to raise_error(Money::Bank::DifferentCurrencyError, "No exchanging of currencies allowed: 1.00 USD to EUR")
    end
  end
end
