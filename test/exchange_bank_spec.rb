$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'money/variable_exchange_bank'

describe Money::VariableExchangeBank do
  before :each do
    @bank = Money::VariableExchangeBank.new
  end

  it "returns the previously specified conversion rate" do
    @bank.add_rate("USD", "EUR", 0.788332676)
    @bank.add_rate("EUR", "YEN", 122.631477)
    @bank.get_rate("USD", "EUR").should == 0.788332676
    @bank.get_rate("EUR", "YEN").should == 122.631477
  end

  it "treats currency names case-insensitively" do
    @bank.add_rate("usd", "eur", 1)
    @bank.get_rate("USD", "EUR").should == 1
    @bank.same_currency?("USD", "usd").should be_true
    @bank.same_currency?("EUR", "usd").should be_false
  end
  
  it "returns nil if the conversion rate is unknown" do
    @bank.get_rate("American Pesos", "EUR").should be_nil
  end

  it "exchanges money from one currency to another according to the specified conversion rates" do
    @bank.add_rate("USD", "EUR", 0.5)
    @bank.add_rate("EUR", "YEN", 10)
    @bank.exchange(10_00, "USD", "EUR").should == 5_00
    @bank.exchange(500_00, "EUR", "YEN").should == 5000_00
  end

  it "rounds the exchanged result down" do
    @bank.add_rate("USD", "EUR", 0.788332676)
    @bank.add_rate("EUR", "YEN", 122.631477)
    @bank.exchange(10_00, "USD", "EUR").should == 788
    @bank.exchange(500_00, "EUR", "YEN").should == 6131573
  end

  it "raises Money::UnknownRate upon conversion if the conversion rate is unknown" do
    block = lambda { @bank.exchange(10, "USD", "EUR") }
    block.should raise_error(Money::UnknownRate)
  end
  
  describe '.exchange' do
    context 'sterling to euros using a rate of 1.39' do
      it 'returns the correct amount' do
        @bank.add_rate('GBP', 'EUR', 1.38)
        @bank.exchange(10000, 'GBP', 'EUR').should == 13800
      end
    end
    
    context 'dollars to euros using a rate of 0.86' do
      it 'returns the correct amount' do
        @bank.add_rate('USD', 'EUR', 0.86)
        @bank.exchange(10000, 'USD', 'EUR').should == 8600
      end
    end

    context 'TND to USD using a rate of 0.67138' do
      it 'returns the correct amount' do
        @bank.add_rate('TND', 'USD', 0.67138)
        @bank.exchange(1000, 'TND', 'USD').should == 67
      end
    end

    context 'USD to TND using a rate of 1.32862' do
      it 'returns the correct amount' do
        @bank.add_rate('USD', 'TND', 1.32862)
        @bank.exchange(1000, 'USD', 'TND').should == 13286
      end
    end
  end
end
