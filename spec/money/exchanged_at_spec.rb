require "spec_helper"

describe Money do
  let(:bank) { Money::Bank::VariableExchange.new }
  let(:currency_dkk) { Money::Currency.new("DKK") }
  let(:currency_eur) { Money::Currency.new("EUR") }

  before do
    bank.add_rate("EUR", "DKK", 7.445)
  end

  describe "#exchange_to" do
    it "calls #get_rate on the bank with the correct arguments" do
      money = Money.new(1000, "EUR", bank)
      money.exchanged_at = Time.new(2004, 1, 1)

      expect(bank).to receive(:get_rate).with(currency_eur, currency_dkk, exchanged_at: Time.new(2004, 1, 1)).and_call_original

      result = money.exchange_to(currency_dkk)

      expect(result.to_f).to eq 74.45
    end
  end
end
