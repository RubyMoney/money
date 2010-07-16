# encoding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'money/money'
require 'money/defaults'

describe Money do
  it "is associated to the singleton instance of VariableExchangeBank by default" do
    Money.new(0).bank.object_id.should == Money::VariableExchangeBank.instance.object_id
  end

  specify "#cents returns the amount of cents passed to the constructor" do
    Money.new(200_00, "USD").cents.should == 200_00
  end

  it "rounds the given cents to an integer" do
    Money.new(1.00, "USD").cents.should == 1
    Money.new(1.01, "USD").cents.should == 1
    Money.new(1.50, "USD").cents.should == 2
  end
  
  specify "#currency returns the currency passed to the constructor" do
    Money.new(200_00, "USD").currency.should == Money::Currency.new("USD")
  end

  specify "#currency_string returns the iso_code of the currency object" do
    Money.new(200_00, "USD").currency_as_string.should == Money::Currency.new("USD").to_s
    Money.new(200_00, "USD").currency_as_string.should == "USD"
    Money.new(200_00, "EUR").currency_as_string.should == "EUR"
    Money.new(200_00, "YEN").currency_as_string.should == "YEN"
  end

  specify "#currency_string= set the currency object using the provided string" do
    obj = Money.new(200_00, "USD")
    obj.currency_as_string = "EUR"
    obj.currency.should == Money::Currency.new("EUR")
    obj.currency_as_string = "YEN"
    obj.currency.should == Money::Currency.new("YEN")
    obj.currency_as_string = "USD"
    obj.currency.should == Money::Currency.new("USD")
  end

  specify "#zero? returns whether the amount is 0" do
    Money.new(0, "USD").should be_zero
    Money.new(0, "EUR").should be_zero
    Money.new(1, "USD").should_not be_zero
    Money.new(10, "YEN").should_not be_zero
    Money.new(-1, "EUR").should_not be_zero
  end

  specify "#nonzero? returns whether the amount is not 0" do
    Money.new(0, "USD").should_not be_nonzero
    Money.new(0, "EUR").should_not be_nonzero
    Money.new(1, "USD").should be_nonzero
    Money.new(10, "YEN").should be_nonzero
    Money.new(-1, "EUR").should be_nonzero
  end

  specify "#nonzero? has the same return-value semantics as Numeric#nonzero?" do
    Money.new(0, "USD").nonzero?.should be_nil

    money = Money.new(1, "USD")
    money.nonzero?.should be_equal(money)
  end

  specify "#exchange_to exchanges the amount via its exchange bank" do
    money = Money.new(100_00, "USD")
    money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
    money.exchange_to("EUR")
  end

  specify "#exchange_to exchanges the amount properly" do
    money = Money.new(100_00, "USD")
    money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
    money.exchange_to("EUR").should == Money.new(200_00, "EUR")
  end

  specify "#== returns true if and only if their amount and currency are equal" do
    Money.new(1_00, "USD").should == Money.new(1_00, "USD")
    Money.new(1_00, "USD").should_not == Money.new(1_00, "EUR")
    Money.new(1_00, "USD").should_not == Money.new(2_00, "USD")
    Money.new(1_00, "USD").should_not == Money.new(99_00, "EUR")
  end

  specify "#== can be used to compare with a String money value" do
    Money.new(1_00, "USD").should == "1.00"
    Money.new(1_00, "USD").should_not == "2.00"
    Money.new(1_00, "GBP").should_not == "1.00"
  end

  specify "#== can be used to compare with a Numeric money value" do
    Money.new(1_00, "USD").should == 1
    Money.new(1_57, "USD").should == 1.57
    Money.new(1_00, "USD").should_not == 2
    Money.new(1_00, "GBP").should_not == 1
  end

  specify "#== can be used to compare with an object that responds to #to_money" do
    klass = Class.new do
      def initialize(money)
        @money = money
      end

      def to_money
        @money
      end
    end

    Money.new(1_00, "USD").should == klass.new(Money.new(1_00, "USD"))
    Money.new(2_50, "USD").should == klass.new(Money.new(2_50, "USD"))
    Money.new(2_50, "USD").should_not == klass.new(Money.new(3_00, "USD"))
    Money.new(1_00, "GBP").should_not == klass.new(Money.new(1_00, "USD"))
  end

  specify "#== returns false if used to compare with an object that doesn't respond to #to_money" do
    Money.new(1_00, "USD").should_not == Object.new
    Money.new(1_00, "USD").should_not == Class
    Money.new(1_00, "USD").should_not == Kernel
    Money.new(1_00, "USD").should_not == /foo/
    Money.new(1_00, "USD").should_not == nil
  end

  specify "#eql? returns true if and only if their amount and currency are equal" do
    Money.new(1_00, "USD").eql?(Money.new(1_00, "USD")).should be true
    Money.new(1_00, "USD").eql?(Money.new(1_00, "EUR")).should be false
    Money.new(1_00, "USD").eql?(Money.new(2_00, "USD")).should be false
    Money.new(1_00, "USD").eql?(Money.new(99_00, "EUR")).should be false
  end

  specify "#eql? can be used to compare with a String money value" do
    Money.new(1_00, "USD").eql?("1.00").should be true
    Money.new(1_00, "USD").eql?("2.00").should be false
    Money.new(1_00, "GBP").eql?("1.00").should be false
  end

  specify "#eql? can be used to compare with a Numeric money value" do
    Money.new(1_00, "USD").eql?(1).should be true
    Money.new(1_57, "USD").eql?(1.57).should be true
    Money.new(1_00, "USD").eql?(2).should be false
    Money.new(1_00, "GBP").eql?(1).should be false
  end

  specify "#eql? can be used to compare with an object that responds to #to_money" do
    klass = Class.new do
      def initialize(money)
        @money = money
      end

      def to_money
        @money
      end
    end

    Money.new(1_00, "USD").eql?(klass.new(Money.new(1_00, "USD"))).should be true
    Money.new(2_50, "USD").eql?(klass.new(Money.new(2_50, "USD"))).should be true
    Money.new(2_50, "USD").eql?(klass.new(Money.new(3_00, "USD"))).should be false
    Money.new(1_00, "GBP").eql?(klass.new(Money.new(1_00, "USD"))).should be false
  end

  specify "#eql? returns false if used to compare with an object that doesn't respond to #to_money" do
    Money.new(1_00, "USD").eql?(Object.new).should be false
    Money.new(1_00, "USD").eql?(Class).should be false
    Money.new(1_00, "USD").eql?(Kernel).should be false
    Money.new(1_00, "USD").eql?(/foo/).should be false
    Money.new(1_00, "USD").eql?(nil).should be false
  end

  specify "#<=> can be used to compare with a String money value" do
    (Money.new(1_00) <=> "1.00").should == 0
    (Money.new(1_00) <=> ".99").should > 0
    (Money.new(1_00) <=> "2.00").should < 0
  end

  specify "#<=> can be used to compare with a Numeric money value" do
    (Money.new(1_00) <=> 1).should == 0
    (Money.new(1_00) <=> 0.99).should > 0
    (Money.new(1_00) <=> 2.00).should < 0
  end

  specify "#<=> can be used to compare with an object that responds to #to_money" do
    klass = Class.new do
      def initialize(money)
        @money = money
      end

      def to_money
        @money
      end
    end

    (Money.new(1_00) <=> klass.new(Money.new(1_00))).should == 0
    (Money.new(1_00) <=> klass.new(Money.new(99))).should > 0
    (Money.new(1_00) <=> klass.new(Money.new(2_00))).should < 0
  end

  specify "#<=> raises ArgumentError when used to compare with an object that doesn't respond to #to_money" do
    expected_message = /comparison .+ failed/
    lambda{ Money.new(1_00) <=> Object.new }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> Class }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> Kernel }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> /foo/ }.should raise_error(ArgumentError, expected_message)
  end

  specify "#* multiplies the money's amount by the multiplier while retaining the currency" do
    (Money.new(1_00, "USD") * 10).should == Money.new(10_00, "USD")
  end

  specify "#/ divides the money's amount by the divisor while retaining the currency" do
    (Money.new(10_00, "USD") / 10).should == Money.new(1_00, "USD")
  end

  specify "#/ -> money / fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
      {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-4, :USD)},
      {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-4, :USD)},
      {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3, :USD)},
    ]
    ts.each do |t|
      (t[:a] / t[:b]).should == t[:c]
    end
  end

  specify "#/ -> money / money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c =>  3.25},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => -3.25},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => -3.25},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c =>  3.25},
    ]
    ts.each do |t|
      (t[:a] / t[:b]).should == t[:c]
    end
  end

  specify "#/ -> money / money (difference currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c =>  1.625},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => -1.625},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => -1.625},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c =>  1.625},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      (t[:a] / t[:b]).should == t[:c]
    end
  end

  specify "#div -> money / fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
      {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-4, :USD)},
      {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-4, :USD)},
      {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3, :USD)},
    ]
    ts.each do |t|
      t[:a].div(t[:b]).should == t[:c]
    end
  end

  specify "#div -> money / money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c =>  3.25},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => -3.25},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => -3.25},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c =>  3.25},
    ]
    ts.each do |t|
      t[:a].div(t[:b]).should == t[:c]
    end
  end

  specify "#div -> money / money (different currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c =>  1.625},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => -1.625},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => -1.625},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c =>  1.625},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      t[:a].div(t[:b]).should == t[:c]
    end
  end

  specify "#divmod -> money `divmod` fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => [Money.new( 3, :USD), Money.new( 1, :USD)]},
      {:a => Money.new( 13, :USD), :b => -4, :c => [Money.new(-4, :USD), Money.new(-3, :USD)]},
      {:a => Money.new(-13, :USD), :b =>  4, :c => [Money.new(-4, :USD), Money.new( 3, :USD)]},
      {:a => Money.new(-13, :USD), :b => -4, :c => [Money.new( 3, :USD), Money.new(-1, :USD)]},
    ]
    ts.each do |t|
      t[:a].divmod(t[:b]).should == t[:c]
    end
  end

  specify "#divmod -> money `divmod` money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c => [ 3, Money.new( 1, :USD)]},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => [-4, Money.new(-3, :USD)]},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => [-4, Money.new( 3, :USD)]},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c => [ 3, Money.new(-1, :USD)]},
    ]
    ts.each do |t|
      t[:a].divmod(t[:b]).should == t[:c]
    end
  end

  specify "#divmod -> money `divmod` money (different currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c => [ 1, Money.new( 5, :USD)]},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => [-2, Money.new(-3, :USD)]},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => [-2, Money.new( 3, :USD)]},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c => [ 1, Money.new(-5, :USD)]},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      t[:a].divmod(t[:b]).should == t[:c]
    end
  end

  specify "#modulo -> money `modulo` fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => -4, :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      t[:a].modulo(t[:b]).should == t[:c]
    end
  end

  specify "#modulo -> money `modulo` money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      t[:a].modulo(t[:b]).should == t[:c]
    end
  end

  specify "#modulo -> money `modulo` money (different currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c => Money.new( 5, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c => Money.new(-5, :USD)},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      t[:a].modulo(t[:b]).should == t[:c]
    end
  end

  specify "#% -> money % fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => -4, :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      (t[:a] % t[:b]).should == t[:c]
    end
  end

  specify "#% -> money % money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      (t[:a] % t[:b]).should == t[:c]
    end
  end

  specify "#% -> money % money (different currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c => Money.new( 5, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => Money.new(-3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => Money.new( 3, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c => Money.new(-5, :USD)},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      (t[:a] % t[:b]).should == t[:c]
    end
  end

  specify "#remainder -> money `remainder` fixnum" do
    ts = [
      {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => -4, :c => Money.new( 1, :USD)},
      {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-1, :USD)},
      {:a => Money.new(-13, :USD), :b => -4, :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      t[:a].remainder(t[:b]).should == t[:c]
    end
  end

  specify "#remainder -> money `remainder` money (same currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :USD), :c => Money.new( 1, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :USD), :c => Money.new( 1, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :USD), :c => Money.new(-1, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :USD), :c => Money.new(-1, :USD)},
    ]
    ts.each do |t|
      t[:a].remainder(t[:b]).should == t[:c]
    end
  end

  specify "#remainder -> money `remainder` money (different currency)" do
    ts = [
      {:a => Money.new( 13, :USD), :b => Money.new( 4, :EUR), :c => Money.new( 5, :USD)},
      {:a => Money.new( 13, :USD), :b => Money.new(-4, :EUR), :c => Money.new( 5, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new( 4, :EUR), :c => Money.new(-5, :USD)},
      {:a => Money.new(-13, :USD), :b => Money.new(-4, :EUR), :c => Money.new(-5, :USD)},
    ]
    ts.each do |t|
      t[:b].should_receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
      t[:a].remainder(t[:b]).should == t[:c]
    end
  end

  specify "#abs correctly returns the absolute value as a new Money object" do
    n = Money.new(-1, :USD)
    n.abs.should == Money.new( 1, :USD)
    n.should     == Money.new(-1, :USD)
  end

  specify "Money.empty creates a new Money object of 0 cents" do
    Money.empty.should == Money.new(0)
  end

  specify "Money.ca_dollar creates a new Money object of the given value in CAD" do
    Money.ca_dollar(50).should == Money.new(50, "CAD")
  end

  specify "Money.ca_dollar creates a new Money object of the given value in USD" do
    Money.us_dollar(50).should == Money.new(50, "USD")
  end

  specify "Money.ca_dollar creates a new Money object of the given value in EUR" do
    Money.euro(50).should == Money.new(50, "EUR")
  end

  specify "Money.new accepts { :currency => 'foo' } as the value for the 'currency' argument" do
    money = Money.new(20, :currency => "EUR")
    money.currency.should == Money::Currency.new("EUR")

    money = Money.new(20, :currency => nil)
    money.currency.should == Money.default_currency
  end

  specify "Money.add_rate works" do
    Money.add_rate("EUR", "USD", 10)
    Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
  end

  specify "Money.to_s works" do
    Money.new(10_00).to_s.should == "10.00"
  end

  specify "Money.to_s works with :subunit_to_unit other than 100" do
    Money.new(10_00, "BHD").to_s.should == "1.00"
  end

  specify "Money.to_s shouldn't have decimal when :subunit_to_unit is 1" do
    Money.new(10_00, "CLP").to_s.should == "1000"
  end

  specify "Money.to_f works" do
    Money.new(10_00).to_f.should == 10.0
  end

  specify "Money.to_f works with :subunit_to_unit other than 100" do
    Money.new(10_00, "BHD").to_f.should == 1.0
  end

  describe "#format" do
    it "returns the monetary value as a string" do
      Money.ca_dollar(100).format.should == "$1.00"
    end

    it "uses the correct :subunit_to_unit" do
      Money.new(10_00, "BHD").format.should == "ب.د1.00"
    end

    it "doesn't display a decimal when :subunit_to_unit is 1" do
      Money.new(10_00, "CLP").format.should == "$1.000"
    end

    specify "respects the delimiter and separator defaults" do
      one_thousand = Proc.new do |currency|
        Money.new(1000_00, currency).format
      end

      # Pounds
      one_thousand["GBP"].should == "£1,000.00"

      # Dollars
      one_thousand["USD"].should == "$1,000.00"
      one_thousand["CAD"].should == "$1,000.00"
      one_thousand["AUD"].should == "$1,000.00"
      one_thousand["NZD"].should == "$1,000.00"
      one_thousand["ZWD"].should == "$1,000.00"

      # Yen
      one_thousand["JPY"].should == "¥1,000.00"
      one_thousand["CNY"].should == "¥10,000.00"

      # Euro
      one_thousand["EUR"].should == "€1,000.00"

      # Rupees
      one_thousand["INR"].should == "₨1,000.00"
      one_thousand["NPR"].should == "₨1,000.00"
      one_thousand["SCR"].should == "₨1,000.00"
      one_thousand["LKR"].should == "₨1,000.00"

      # Brazilian Real
      one_thousand["BRL"].should == "R$ 1.000,00"

      # Other
      one_thousand["SEK"].should == "kr1,000.00"
      one_thousand["GHC"].should == "₵1,000.00"
    end

    describe "if the monetary value is 0" do
      before :each do
        @money = Money.us_dollar(0)
      end

      it "returns 'free' when :display_free is true" do
        @money.format(:display_free => true).should == 'free'
      end

      it "returns '$0.00' when :display_free is false or not given" do
        @money.format.should == '$0.00'
        @money.format(:display_free => false).should == '$0.00'
        @money.format(:display_free => nil).should == '$0.00'
      end

      it "returns the value specified by :display_free if it's a string-like object" do
        @money.format(:display_free => 'gratis').should == 'gratis'
      end
    end


    specify "#symbol works as documented" do
      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return("€")
      Money.empty(currency).symbol.should == "€"

      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return(nil)
      Money.empty(currency).symbol.should == "¤"
    end

    specify "#delimiter works as documented" do
      Money.empty("USD").delimiter.should == ","
      Money.empty("EUR").delimiter.should == ","
      Money.empty("BRL").delimiter.should == "."
    end

    specify "#separator works as documented" do
      Money.empty("USD").separator.should == "."
      Money.empty("EUR").separator.should == "."
      Money.empty("BRL").separator.should == ","
    end

    specify "#format(:with_currency => true) works as documented" do
      Money.ca_dollar(100).format(:with_currency => true).should == "$1.00 CAD"
      Money.us_dollar(85).format(:with_currency => true).should == "$0.85 USD"
      Money.us_dollar(85).format(:with_currency).should == "$0.85 USD"
    end

    specify "#format(:with_currency) works as documented" do
      Money.ca_dollar(100).format(:with_currency).should == "$1.00 CAD"
      Money.us_dollar(85).format(:with_currency).should == "$0.85 USD"
    end

    specify "#format(:no_cents => true) works as documented" do
      Money.ca_dollar(100).format(:no_cents => true).should == "$1"
      Money.ca_dollar(599).format(:no_cents => true).should == "$5"
      Money.ca_dollar(570).format(:no_cents => true, :with_currency => true).should == "$5 CAD"
      Money.ca_dollar(39000).format(:no_cents => true).should == "$390"
    end

    specify "#format(:no_cents => true) uses correct :subunit_to_unit" do
      Money.new(10_00, "BHD").format(:no_cents => true).should == "ب.د1"
    end

    specify "#format(:no_cents) works as documented" do
      Money.ca_dollar(100).format(:no_cents).should == "$1"
      Money.ca_dollar(599).format(:no_cents).should == "$5"
      Money.ca_dollar(570).format(:no_cents, :with_currency).should == "$5 CAD"
      Money.ca_dollar(39000).format(:no_cents).should == "$390"
    end

    specify "#format(:no_cents) uses correct :subunit_to_unit" do
      Money.new(10_00, "BHD").format(:no_cents).should == "ب.د1"
    end

    specify "#format(:symbol => a symbol string) uses the given value as the money symbol" do
      Money.new(100, "GBP").format(:symbol => "£").should == "£1.00"
    end

    specify "#format(:symbol => true) returns symbol based on the given currency code" do
      one = Proc.new do |currency|
        Money.new(100, currency).format(:symbol => true)
      end

      # Pounds
      one["GBP"].should == "£1.00"

      # Dollars
      one["USD"].should == "$1.00"
      one["CAD"].should == "$1.00"
      one["AUD"].should == "$1.00"
      one["NZD"].should == "$1.00"
      one["ZWD"].should == "$1.00"

      # Yen
      one["JPY"].should == "¥1.00"
      one["CNY"].should == "¥10.00"

      # Euro
      one["EUR"].should == "€1.00"

      # Rupees
      one["INR"].should == "₨1.00"
      one["NPR"].should == "₨1.00"
      one["SCR"].should == "₨1.00"
      one["LKR"].should == "₨1.00"

      # Brazilian Real
      one["BRL"].should == "R$ 1,00"

      # Other
      one["SEK"].should == "kr1.00"
      one["GHC"].should == "₵1.00"
    end

    specify "#format(:symbol => true) returns $ when currency code is not recognized" do
      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return(nil)
      Money.new(100, currency).format(:symbol => true).should == "¤1.00"
    end

    specify "#format(:symbol => some non-Boolean value that evaluates to true) returs symbol based on the given currency code" do
      Money.new(100, "GBP").format(:symbol => true).should == "£1.00"
      Money.new(100, "EUR").format(:symbol => true).should == "€1.00"
      Money.new(100, "SEK").format(:symbol => true).should == "kr1.00"
    end

    specify "#format with :symbol == "", nil or false returns the amount without a symbol" do
      money = Money.new(100, "GBP")
      money.format(:symbol => "").should == "1.00"
      money.format(:symbol => nil).should == "1.00"
      money.format(:symbol => false).should == "1.00"
    end

    specify "#format without :symbol assumes that :symbol is set to true" do
      money = Money.new(100)
      money.format.should == "$1.00"

      money = Money.new(100, "GBP")
      money.format.should == "£1.00"

      money = Money.new(100, "EUR")
      money.format.should == "€1.00"
    end

    specify "#format(:separator => a separator string) works as documented" do
      Money.us_dollar(100).format(:separator => ",").should == "$1,00"
    end

    specify "#format will default separator to '.' if currency isn't recognized" do
      Money.new(100, "ZWD").format.should == "$1.00"
    end

    specify "#format(:delimiter => a delimiter string) works as documented" do
      Money.us_dollar(100000).format(:delimiter => ".").should == "$1.000.00"
      Money.us_dollar(200000).format(:delimiter => "").should  == "$2000.00"
    end

    specify "#format(:delimiter => false or nil) works as documented" do
      Money.us_dollar(100000).format(:delimiter => false).should == "$1000.00"
      Money.us_dollar(200000).format(:delimiter => nil).should   == "$2000.00"
    end

    specify "#format will default delimiter to ',' if currency isn't recognized" do
      Money.new(100000, "ZWD").format.should == "$1,000.00"
    end

    specify "#format(:html => true) works as documented" do
      string = Money.ca_dollar(570).format(:html => true, :with_currency => true)
      string.should == "$5.70 <span class=\"currency\">CAD</span>"
    end

    it "should insert commas into the result if the amount is sufficiently large" do
      Money.us_dollar(1_000_000_000_12).format.should == "$1,000,000,000.12"
      Money.us_dollar(1_000_000_000_12).format(:no_cents => true).should == "$1,000,000,000"
    end
  end


  # Sets $VERBOSE to nil for the duration of the block and back to its original value afterwards.
  #
  #   silence_warnings do
  #     value = noisy_call # no warning voiced
  #   end
  #
  #   noisy_call # warning voiced
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

end

describe "Actions involving two Money objects" do
  describe "if the other Money object has the same currency" do
    specify "#<=> compares the two objects' amounts" do
      (Money.new(1_00, "USD") <=> Money.new(1_00, "USD")).should == 0
      (Money.new(1_00, "USD") <=> Money.new(99, "USD")).should > 0
      (Money.new(1_00, "USD") <=> Money.new(2_00, "USD")).should < 0
    end

    specify "#+ adds the other object's amount to the current object's amount while retaining the currency" do
      (Money.new(10_00, "USD") + Money.new(90, "USD")).should == Money.new(10_90, "USD")
    end

    specify "#- substracts the other object's amount from the current object's amount while retaining the currency" do
      (Money.new(10_00, "USD") - Money.new(90, "USD")).should == Money.new(9_10, "USD")
    end

    specify "#/ divides the current object's amount by the other object's amount resulting in a float" do
      (Money.new(10_00, "USD") / Money.new(100_00, "USD")).should == 0.1
    end
  end

  describe "if the other Money object has a different currency" do
    specify "#<=> compares the two objects' amount after converting the other object's amount to its own currency" do
      target = Money.new(200_00, "EUR")
      target.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(300_00, "USD"))
      (Money.new(100_00, "USD") <=> target).should < 0

      target = Money.new(200_00, "EUR")
      target.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(100_00, "USD"))
      (Money.new(100_00, "USD") <=> target).should == 0

      target = Money.new(200_00, "EUR")
      target.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(99_00, "USD"))
      (Money.new(100_00, "USD") <=> target).should > 0
    end

    specify "#+ adds the other object's amount, converted to this object's currency, to this object's amount while retaining its currency" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") + other).should == Money.new(19_00, "USD")
    end

    specify "#- substracts the other object's amount, converted to this object's currency, from this object's amount while retaining its currency" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") - other).should == Money.new(1_00, "USD")
    end

    specify "#/ divides the this object's amount by the other objects's amount, converted to this object's currency, resulting in a float" do
      other = Money.new(1000, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(100_00, "USD"))
      (Money.new(10_00, "USD") / other).should == 0.1
    end
  end
end
