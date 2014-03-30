require 'spec_helper'

describe Money::Bank::SingleCurrency do
  describe "#exchange_with" do
    it "raises when called" do
      expect {
        subject.exchange_with(Money.new(100, 'USD'), 'EUR')
      }.to raise_exception(Money::Bank::DifferentCurrencyError, "No exchanging of currencies allowed: 1.00 USD to EUR")
    end

    context "the currencies match" do
      it "returns the value unchanged" do
        expect(subject.exchange_with(Money.new(100, 'USD'), 'USD')).to eq(Money.new(100, 'USD'))
      end
    end
  end
end
