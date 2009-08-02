$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
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
    "20.15".to_money.should == Money.new(20_15)
    "100".to_money.should == Money.new(100_00)
    "100.37".to_money.should == Money.new(100_37)
    "100,37".to_money.should == Money.new(100_37)
    "100 000".to_money.should == Money.new(100_000_00)
    "100,000.00".to_money.should == Money.new(100_000_00)
    "1,000".to_money.should == Money.new(1_000_00)
    "-1,000".to_money.should == Money.new(-1_000_00)
    "1,000.5".to_money.should == Money.new(1_000_50)
    "1,000.51".to_money.should == Money.new(1_000_51)
    "1,000.505".to_money.should == Money.new(1_000_51)
    "1,000.504".to_money.should == Money.new(1_000_50)
    "1,000.0000".to_money.should == Money.new(1_000_00)
    "1,000.5000".to_money.should == Money.new(1_000_50)
    "1,000.5099".to_money.should == Money.new(1_000_51)
    "1.550".to_money.should == Money.new(1_55)
    "25.".to_money.should == Money.new(25_00)
    ".75".to_money.should == Money.new(75)
    
    "100 USD".to_money.should == Money.new(100_00, "USD")
    "-100 USD".to_money.should == Money.new(-100_00, "USD")
    "100 EUR".to_money.should == Money.new(100_00, "EUR")
    "100.37 EUR".to_money.should == Money.new(100_37, "EUR")
    "100,37 EUR".to_money.should == Money.new(100_37, "EUR")
    "100,000.00 USD".to_money.should == Money.new(100_000_00, "USD")
    "100.000,00 EUR".to_money.should == Money.new(100_000_00, "EUR")
    "1,000 USD".to_money.should == Money.new(1_000_00, "USD")
    "-1,000 USD".to_money.should == Money.new(-1_000_00, "USD")
    "1,000.5500 USD".to_money.should == Money.new(1_000_55, "USD")
    "-1,000.6500 USD".to_money.should == Money.new(-1_000_65, "USD")
    "1.550 USD".to_money.should == Money.new(1_55, "USD")
    
    "USD 100".to_money.should == Money.new(100_00, "USD")
    "EUR 100".to_money.should == Money.new(100_00, "EUR")
    "EUR 100.37".to_money.should == Money.new(100_37, "EUR")
    "CAD -100.37".to_money.should == Money.new(-100_37, "CAD")
    "EUR 100,37".to_money.should == Money.new(100_37, "EUR")
    "EUR -100,37".to_money.should == Money.new(-100_37, "EUR")
    "USD 100,000.00".to_money.should == Money.new(100_000_00, "USD")
    "EUR 100.000,00".to_money.should == Money.new(100_000_00, "EUR")
    "USD 1,000".to_money.should == Money.new(1_000_00, "USD")
    "USD -1,000".to_money.should == Money.new(-1_000_00, "USD")
    "USD 1,000.9000".to_money.should == Money.new(1_000_90, "USD")
    "USD -1,000.090".to_money.should == Money.new(-1_000_09, "USD")
    "USD 1.5500".to_money.should == Money.new(1_55, "USD")
    
    "$100 USD".to_money.should == Money.new(100_00, "USD")
    "$1,194.59 USD".to_money.should == Money.new(1_194_59, "USD")
    "$-1,955 USD".to_money.should == Money.new(-1_955_00, "USD")
    "$1,194.5900 USD".to_money.should == Money.new(1_194_59, "USD")
    "$-1,955.000 USD".to_money.should == Money.new(-1_955_00, "USD")
    "$1.99000 USD".to_money.should == Money.new(1_99, "USD")
  end
  
  specify "String#to_money ignores unrecognized data" do
    "hello 2000 world".to_money.should == Money.new(2000_00)
  end
end
