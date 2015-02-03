require 'spec_helper'

class Money
  module Bank
    describe SingleCurrency do
      describe "#exchange_with" do
        it "raises when called" do
          expect {
            subject.exchange_with(Money.new(100, 'USD'), 'EUR')
          }.to raise_exception(DifferentCurrencyError, "No exchanging of currencies allowed: 1.00 USD to EUR")
        end
      end
    end
  end
end
