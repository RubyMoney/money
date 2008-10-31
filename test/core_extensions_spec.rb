$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'money/core_extensions'

describe "Money core extensions" do
	specify "Numberic#to_money works" do
		money = 1234.to_money
		money.cents.should == 1234_00
		money.currency.should == Money.default_currency
		
		money = 100.37.to_money
		money.cents.should == 100_37
		money.currency.should == Money.default_currency
	end
	
	specify "String#to_money works" do
		"100".to_money.should == Money.new(100_00)
		"100.37".to_money.should == Money.new(100_37)
		"100,37".to_money.should == Money.new(100_37)
		"100 000".to_money.should == Money.new(100_000_00)
		
		"100 USD".to_money.should == Money.new(100_00, "USD")
		"100 EUR".to_money.should == Money.new(100_00, "EUR")
		"100.37 EUR".to_money.should == Money.new(100_37, "EUR")
		"100,37 EUR".to_money.should == Money.new(100_37, "EUR")
		
		"USD 100".to_money.should == Money.new(100_00, "USD")
		"EUR 100".to_money.should == Money.new(100_00, "EUR")
		"EUR 100.37".to_money.should == Money.new(100_37, "EUR")
		"EUR 100,37".to_money.should == Money.new(100_37, "EUR")
		
		"$100 USD".to_money.should == Money.new(100_00, "USD")
	end
end
