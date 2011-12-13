require "spec_helper"

describe Money, "core extensions" do

  describe Numeric do
    describe "#to_money" do
      it "work as documented" do
        money = 1234.to_money
        money.cents.should == 1234_00
        money.currency.should == Money.default_currency

        money = 100.37.to_money
        money.cents.should == 100_37
        money.currency.should == Money.default_currency

        money = BigDecimal.new('1234').to_money
        money.cents.should == 1234_00
        money.currency.should == Money.default_currency
      end

      it "accepts optional currency" do
        1234.to_money('USD').should == Money.new(123400, 'USD')
        1234.to_money('EUR').should == Money.new(123400, 'EUR')
      end

      it "respects :subunit_to_unit currency property" do
        10.to_money('USD').should == Money.new(10_00, 'USD')
        10.to_money('TND').should == Money.new(10_000, 'TND')
        10.to_money('CLP').should == Money.new(10, 'CLP')
      end

      specify "GH-15" do
        amount = 555.55.to_money
        amount.should == Money.new(55555)
      end
    end
  end

  describe String do
    describe "#to_money" do

      STRING_TO_MONEY = {
        "20.15"           => Money.new(20_15)             ,
        "100"             => Money.new(100_00)            ,
        "100.37"          => Money.new(100_37)            ,
        "100,37"          => Money.new(100_37)            ,
        "100 000"         => Money.new(100_000_00)        ,
        "100,000.00"      => Money.new(100_000_00)        ,
        "1,000"           => Money.new(1_000_00)          ,
        "-1,000"          => Money.new(-1_000_00)         ,
        "1,000.5"         => Money.new(1_000_50)          ,
        "1,000.51"        => Money.new(1_000_51)          ,
        "1,000.505"       => Money.new(1_000_51)          ,
        "1,000.504"       => Money.new(1_000_50)          ,
        "1,000.0000"      => Money.new(1_000_00)          ,
        "1,000.5000"      => Money.new(1_000_50)          ,
        "1,000.5099"      => Money.new(1_000_51)          ,
        "1.550"           => Money.new(1_55)              ,
        "25."             => Money.new(25_00)             ,
        ".75"             => Money.new(75)                ,

        "100 USD"         => Money.new(100_00, "USD")     ,
        "-100 USD"        => Money.new(-100_00, "USD")    ,
        "100 EUR"         => Money.new(100_00, "EUR")     ,
        "100.37 EUR"      => Money.new(100_37, "EUR")     ,
        "100,37 EUR"      => Money.new(100_37, "EUR")     ,
        "100,000.00 USD"  => Money.new(100_000_00, "USD") ,
        "100.000,00 EUR"  => Money.new(100_000_00, "EUR") ,
        "1,000 USD"       => Money.new(1_000_00, "USD")   ,
        "-1,000 USD"      => Money.new(-1_000_00, "USD")  ,
        "1,000.5500 USD"  => Money.new(1_000_55, "USD")   ,
        "-1,000.6500 USD" => Money.new(-1_000_65, "USD")  ,
        "1.550 USD"       => Money.new(1_55, "USD")       ,

        "USD 100"         => Money.new(100_00, "USD")     ,
        "EUR 100"         => Money.new(100_00, "EUR")     ,
        "EUR 100.37"      => Money.new(100_37, "EUR")     ,
        "CAD -100.37"     => Money.new(-100_37, "CAD")    ,
        "EUR 100,37"      => Money.new(100_37, "EUR")     ,
        "EUR -100,37"     => Money.new(-100_37, "EUR")    ,
        "USD 100,000.00"  => Money.new(100_000_00, "USD") ,
        "EUR 100.000,00"  => Money.new(100_000_00, "EUR") ,
        "USD 1,000"       => Money.new(1_000_00, "USD")   ,
        "USD -1,000"      => Money.new(-1_000_00, "USD")  ,
        "USD 1,000.9000"  => Money.new(1_000_90, "USD")   ,
        "USD -1,000.090"  => Money.new(-1_000_09, "USD")  ,
        "USD 1.5500"      => Money.new(1_55, "USD")       ,

        "$100 USD"        => Money.new(100_00, "USD")     ,
        "$1,194.59 USD"   => Money.new(1_194_59, "USD")   ,
        "$-1,955 USD"     => Money.new(-1_955_00, "USD")  ,
        "$1,194.5900 USD" => Money.new(1_194_59, "USD")   ,
        "$-1,955.000 USD" => Money.new(-1_955_00, "USD")  ,
        "$1.99000 USD"    => Money.new(1_99, "USD")       ,
      }

      it "works as documented" do
        STRING_TO_MONEY.each do |string, money|
          string.to_money.should == money
        end
      end

      it "coerces input to string" do
        Money.parse(20, "USD").should == Money.new(20_00, "USD")
      end

      it "accepts optional currency" do
        "10.10".to_money('USD').should == Money.new(1010, 'USD')
        "10.10".to_money('EUR').should == Money.new(1010, 'EUR')
        "10.10 USD".to_money('USD').should == Money.new(1010, 'USD')
      end

      it "raises error if optional currency doesn't match string currency" do
        expect { "10.10 USD".to_money('EUR') }.to raise_error(/Mismatching Currencies/)
      end

      it "ignores unrecognized data" do
        "hello 2000 world".to_money.should == Money.new(2000_00)
      end

      it "respects :subunit_to_unit currency property" do
        "1".to_money("USD").should == Money.new(1_00,  "USD")
        "1".to_money("TND").should == Money.new(1_000, "TND")
        "1".to_money("CLP").should == Money.new(1,     "CLP")
        "1.5".to_money("KWD").cents.should == 1500
      end
    end

    describe "#to_currency" do
      it "converts String to Currency" do
        "USD".to_currency.should == Money::Currency.new("USD")
        "EUR".to_currency.should == Money::Currency.new("EUR")
      end

      it "raises Money::Currency::UnknownCurrency with unknown Currency" do
        expect { "XXX".to_currency }.to raise_error(Money::Currency::UnknownCurrency)
        expect { " ".to_currency }.to raise_error(Money::Currency::UnknownCurrency)
      end
    end
  end

  describe Symbol do
    describe "#to_currency" do
      it "converts Symbol to Currency" do
        :usd.to_currency.should == Money::Currency.new("USD")
        :ars.to_currency.should == Money::Currency.new("ARS")
      end

      it "is case-insensitive" do
        :EUR.to_currency.should == Money::Currency.new("EUR")
      end

      it "raises Money::Currency::UnknownCurrency with unknown Currency" do
        expect { :XXX.to_currency }.to raise_error(Money::Currency::UnknownCurrency)
        expect { :" ".to_currency }.to raise_error(Money::Currency::UnknownCurrency)
      end
    end
  end

end
