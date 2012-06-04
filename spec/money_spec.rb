# encoding: utf-8

require "spec_helper"

describe Money do
  describe ".new" do
    it "rounds the given cents to an integer" do
      Money.new(1.00, "USD").cents.should == 1
      Money.new(1.01, "USD").cents.should == 1
      Money.new(1.50, "USD").cents.should == 2
    end

    it "is associated to the singleton instance of Bank::VariableExchange by default" do
      Money.new(0).bank.should be(Money::Bank::VariableExchange.instance)
    end

    it "handles Rationals" do
      n = Rational(1)
      Money.new(n).cents.should == 1
    end

    it "handles Floats" do
      n = Float("1")
      Money.new(n).cents.should == 1
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "doesn't round cents" do
        Money.new(1.01, "USD").cents.should == BigDecimal("1.01")
        Money.new(1.50, "USD").cents.should == BigDecimal("1.50")
      end
    end
  end

  describe ".new_with_dollars" do
    it "converts given amount to cents" do
      Money.new_with_dollars(1).should == Money.new(100)
      Money.new_with_dollars(1, "USD").should == Money.new(100, "USD")
      Money.new_with_dollars(1, "EUR").should == Money.new(100, "EUR")
    end

    it "respects :subunit_to_unit currency property" do
      Money.new_with_dollars(1, "USD").should == Money.new(1_00,  "USD")
      Money.new_with_dollars(1, "TND").should == Money.new(1_000, "TND")
      Money.new_with_dollars(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "does not loose precision" do
      Money.new_with_dollars(1234).cents.should == 1234_00
      Money.new_with_dollars(100.37).cents.should == 100_37
      Money.new_with_dollars(BigDecimal.new('1234')).cents.should == 1234_00
    end

    it "accepts optional currency" do
      m = Money.new_with_dollars(1)
      m.currency.should == Money.default_currency

      m = Money.new_with_dollars(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.new_with_dollars(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end

    it "accepts optional bank" do
      m = Money.new_with_dollars(1)
      m.bank.should == Money.default_bank

      m = Money.new_with_dollars(1, "EUR", bank = Object.new)
      m.bank.should == bank
    end

    it "is associated to the singleton instance of Bank::VariableExchange by default" do
      Money.new_with_dollars(0).bank.should be(Money::Bank::VariableExchange.instance)
    end
  end

  describe ".empty" do
    it "creates a new Money object of 0 cents" do
      Money.empty.should == Money.new(0)
    end
  end

  describe ".ca_dollar" do
    it "creates a new Money object of the given value in CAD" do
      Money.ca_dollar(50).should == Money.new(50, "CAD")
    end
  end

  describe ".us_dollar" do
    it "creates a new Money object of the given value in USD" do
      Money.us_dollar(50).should == Money.new(50, "USD")
    end
  end

  describe ".euro" do
    it "creates a new Money object of the given value in EUR" do
      Money.euro(50).should == Money.new(50, "EUR")
    end
  end

  describe ".add_rate" do
    it "saves rate into current bank" do
      Money.add_rate("EUR", "USD", 10)
      Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
    end
  end


  describe "#cents" do
    it "returns the amount of cents" do
      Money.new(1_00).cents.should == 1_00
      Money.new_with_dollars(1).cents.should == 1_00
    end

    it "stores cents as an integer regardless of what is passed into the constructor" do
      [ Money.new(100), 1.to_money, 1.00.to_money, BigDecimal('1.00').to_money ].each do |m|
        m.cents.should == 100
        m.cents.should be_a(Fixnum)
      end
    end

    context "user changes rounding_mode" do
      after do
        Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
      end

      it "respects the rounding_mode" do
        Money.rounding_mode = BigDecimal::ROUND_DOWN
        Money.new(1.9).cents.should == 1

        Money.rounding_mode = BigDecimal::ROUND_UP
        Money.new(1.1).cents.should == 2
      end
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "returns the amount of cents" do
        Money.new(1_00).cents.should == BigDecimal("100")
        Money.new_with_dollars(1).cents.should == BigDecimal("100")
      end

      it "stores cents as an integer regardless of what is passed into the constructor" do
        [ Money.new(100), 1.to_money, 1.00.to_money, BigDecimal('1.00').to_money ].each do |m|
          m.cents.should == BigDecimal("100")
          m.cents.should be_a(BigDecimal)
        end
      end
    end
  end

  describe "#dollars" do
    it "returns the amount of cents as dollars" do
      Money.new(1_00).dollars.should == 1
      Money.new_with_dollars(1).dollars.should == 1
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(1_00,  "USD").dollars.should == 1
      Money.new(1_000, "TND").dollars.should == 1
      Money.new(1,     "CLP").dollars.should == 1
    end

    it "does not loose precision" do
      Money.new(100_37).dollars.should == 100.37
      Money.new_with_dollars(100.37).dollars.should == 100.37
    end
  end

  describe "#currency" do
    it "returns the currency object" do
      Money.new(1_00, "USD").currency.should == Money::Currency.new("USD")
    end
  end

  describe "#currency_as_string" do
    it "returns the iso_code of the currency object" do
      Money.new(1_00, "USD").currency_as_string.should == "USD"
      Money.new(1_00, "EUR").currency_as_string.should == "EUR"
    end
  end

  describe "#currency_as_string=" do
    it "sets the currency object using the provided string" do
      money = Money.new(100_00, "USD")
      money.currency_as_string = "EUR"
      money.currency.should == Money::Currency.new("EUR")
      money.currency_as_string = "YEN"
      money.currency.should == Money::Currency.new("YEN")
    end
  end

  describe "#hash=" do
    it "returns the same value for equal objects" do
      Money.new(1_00, "EUR").hash.should == Money.new(1_00, "EUR").hash
      Money.new(2_00, "USD").hash.should == Money.new(2_00, "USD").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(2_00, "EUR").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(1_00, "USD").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(2_00, "USD").hash
    end

    it "can be used to return the intersection of Money object arrays" do
      intersection = [Money.new(1_00, "EUR"), Money.new(1_00, "USD")] & [Money.new(1_00, "EUR")]
      intersection.should == [Money.new(1_00, "EUR")]
    end
  end

  describe "#symbol" do
    it "works as documented" do
      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return("€")
      Money.empty(currency).symbol.should == "€"

      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return(nil)
      Money.empty(currency).symbol.should == "¤"
    end
  end

  describe "#to_s" do
    it "works as documented" do
      Money.new(10_00).to_s.should == "10.00"
      Money.new(400_08).to_s.should == "400.08"
      Money.new(-237_43).to_s.should == "-237.43"
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").to_s.should == "1.000"
      Money.new(10_00, "CNY").to_s.should == "10.00"
    end

    it "does not have decimal when :subunit_to_unit == 1" do
      Money.new(10_00, "CLP").to_s.should == "1000"
    end

    it "does not work when :subunit_to_unit == 5" do
      Money.new(10_00, "MGA").to_s.should == "200.0"
    end

    it "respects :decimal_mark" do
      Money.new(10_00, "BRL").to_s.should == "10,00"
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "shows fractional cents" do
        Money.new(1.05, "USD").to_s.should == "0.0105"
      end

      it "suppresses fractional cents when there is none" do
        Money.new(1.0, "USD").to_s.should == "0.01"
      end
    end
  end

  describe "#to_d" do
    it "works as documented" do
      decimal = Money.new(10_00).to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 10.0
    end

    it "respects :subunit_to_unit currency property" do
      decimal = Money.new(10_00, "BHD").to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 1.0
    end

    it "works with float :subunit_to_unit currency property" do
      money = Money.new(10_00, "BHD")
      money.currency.stub(:subunit_to_unit).and_return(1000.0)

      decimal = money.to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 1.0
    end
  end

  describe "#to_f" do
    it "works as documented" do
      Money.new(10_00).to_f.should == 10.0
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").to_f.should == 1.0
    end
  end

  describe "#to_money" do
    it "works as documented" do
      money = Money.new(10_00, "DKK")
      money.should == money.to_money
      money.should == money.to_money("DKK")
      money.bank.should_receive(:exchange_with).with(Money.new(10_00, Money::Currency.new("DKK")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.to_money("EUR").should == Money.new(200_00, "EUR")
    end
  end

  describe "#exchange_to" do
    it "exchanges the amount via its exchange bank" do
      money = Money.new(100_00, "USD")
      money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.exchange_to("EUR")
    end

    it "exchanges the amount properly" do
      money = Money.new(100_00, "USD")
      money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.exchange_to("EUR").should == Money.new(200_00, "EUR")
    end
  end

  describe "#allocate" do
    it "takes no action when one gets all" do
      Money.us_dollar(005).allocate([1.0]).should == [Money.us_dollar(5)]
    end

    it "keeps currencies intact" do
      Money.ca_dollar(005).allocate([1]).should == [Money.ca_dollar(5)]
    end

    it "does not loose pennies" do
      moneys = Money.us_dollar(5).allocate([0.3, 0.7])
      moneys[0].should == Money.us_dollar(2)
      moneys[1].should == Money.us_dollar(3)
    end

    it "does not loose pennies" do
      moneys = Money.us_dollar(100).allocate([0.333, 0.333, 0.333])
      moneys[0].cents.should == 34
      moneys[1].cents.should == 33
      moneys[2].cents.should == 33
    end

    it "requires total to be less then 1" do
      expect { Money.us_dollar(0.05).allocate([0.5, 0.6]) }.to raise_error(ArgumentError)
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "allows for fractional cents allocation" do
        one_third = BigDecimal("1") / BigDecimal("3")

        moneys = Money.new(100).allocate([one_third, one_third, one_third])
        moneys[0].cents.should == one_third * BigDecimal("100")
        moneys[1].cents.should == one_third * BigDecimal("100")
        moneys[2].cents.should == one_third * BigDecimal("100")
      end
    end
  end

  describe "#split" do
    it "needs at least one party" do
      expect { Money.us_dollar(1).split(0) }.to raise_error(ArgumentError)
      expect { Money.us_dollar(1).split(-1) }.to raise_error(ArgumentError)
    end

    it "gives 1 cent to both people if we start with 2" do
      Money.us_dollar(2).split(2).should == [Money.us_dollar(1), Money.us_dollar(1)]
    end

    it "may distribute no money to some parties if there isnt enough to go around" do
      Money.us_dollar(2).split(3).should == [Money.us_dollar(1), Money.us_dollar(1), Money.us_dollar(0)]
    end

    it "does not lose pennies" do
      Money.us_dollar(5).split(2).should == [Money.us_dollar(3), Money.us_dollar(2)]
    end

    it "splits a dollar" do
      moneys = Money.us_dollar(100).split(3)
      moneys[0].cents.should == 34
      moneys[1].cents.should == 33
      moneys[2].cents.should == 33
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "allows for splitting by fractional cents" do
        thirty_three_and_one_third = BigDecimal("100") / BigDecimal("3")

        moneys = Money.new(100).split(3)
        moneys[0].cents.should == thirty_three_and_one_third
        moneys[1].cents.should == thirty_three_and_one_third
        moneys[2].cents.should == thirty_three_and_one_third
      end
    end
  end
end
