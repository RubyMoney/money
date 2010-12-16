# encoding: utf-8

require "spec_helper"

describe Money do

  describe "#new" do
    it "rounds the given cents to an integer" do
      Money.new(1.00, "USD").cents.should == 1
      Money.new(1.01, "USD").cents.should == 1
      Money.new(1.50, "USD").cents.should == 2
    end

    it "is associated to the singleton instance of Bank::VariableExchange by default" do
      Money.new(0).bank.should be_equal(Money::Bank::VariableExchange.instance)
    end

  end

  describe "#cents" do
    it "returns the amount of cents passed to the constructor" do
      Money.new(200_00, "USD").cents.should == 200_00
    end
  end

  describe "#dollars" do
    it "gets cents as dollars" do
      Money.new_with_dollars(1).should == Money.new(100)
      Money.new_with_dollars(1, "USD").should == Money.new(100, "USD")
      Money.new_with_dollars(1, "EUR").should == Money.new(100, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.new(1_00,  "USD").dollars.should == 1
      Money.new(1_000, "TND").dollars.should == 1
      Money.new(1,     "CLP").dollars.should == 1
    end

    it "should not loose precision" do
      Money.new(100_37).dollars.should == 100.37
      Money.new_with_dollars(100.37).dollars.should == 100.37
    end
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

  specify "#hash should return the same value for equal objects" do
    Money.new(1_00, :eur).hash.should == Money.new(1_00, :eur).hash
    Money.new(2_00, :usd).hash.should == Money.new(2_00, :usd).hash
    Money.new(1_00, :eur).hash.should_not == Money.new(2_00, :eur).hash
    Money.new(1_00, :eur).hash.should_not == Money.new(1_00, :usd).hash
    Money.new(1_00, :eur).hash.should_not == Money.new(2_00, :usd).hash
  end

  specify "#hash can be used to return the intersection of Money object arrays" do
    intersection = [Money.new(1_00, :eur), Money.new(1_00, :usd)] & [Money.new(1_00, :eur)]
    intersection.should == [Money.new(1_00, :eur)]
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
    expected_message = /Comparison .+ failed/
    lambda{ Money.new(1_00) <=> Object.new  }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> Class       }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> Kernel      }.should raise_error(ArgumentError, expected_message)
    lambda{ Money.new(1_00) <=> /foo/       }.should raise_error(ArgumentError, expected_message)
  end

  describe "#*" do
    it "should multiply current money amount by the multiplier while retaining the currency" do
      (Money.new(1_00, "USD") * 10).should == Money.new(10_00, "USD")
    end

    it "should multiply Money by Fixnum and returns Money" do
      ts = [
        {:a => Money.new( 10, :USD), :b =>  4, :c => Money.new( 40, :USD)},
        {:a => Money.new( 10, :USD), :b => -4, :c => Money.new(-40, :USD)},
        {:a => Money.new(-10, :USD), :b =>  4, :c => Money.new(-40, :USD)},
        {:a => Money.new(-10, :USD), :b => -4, :c => Money.new( 40, :USD)},
      ]
      ts.each do |t|
        (t[:a] * t[:b]).should == t[:c]
      end
    end

    it "should not multiply Money by Money (same currency)" do
      lambda { Money.new( 10, :USD) * Money.new( 4, :USD) }.should raise_error(ArgumentError)
    end

    it "should not multiply Money by Money (different currency)" do
      lambda { Money.new( 10, :USD) * Money.new( 4, :EUR) }.should raise_error(ArgumentError)
    end
  end

  describe "#/" do
    it "divides current money amount by the divisor while retaining the currency" do
      (Money.new(10_00, "USD") / 10).should == Money.new(1_00, "USD")
    end

    it "divides Money by Fixnum and returns Money" do
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

    it "divides Money by Money (same currency) and returns Float" do
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

    it "divides Money by Money (different currency) and returns Float" do
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

  specify "Money.format brute force :subunit_to_unit = 1" do
    ("0".."9").each do |amt|
      amt.to_money("VUV").format(:symbol => false).should == amt
    end
    ("-1".."-9").each do |amt|
      amt.to_money("VUV").format(:symbol => false).should == amt
    end
    "1000".to_money("VUV").format(:symbol => false).should == "1,000"
    "-1000".to_money("VUV").format(:symbol => false).should == "-1,000"
  end

  specify "Money.format brute force :subunit_to_unit = 5" do
    ("0.0".."9.4").each do |amt|
      next if amt[-1].to_i > 4
      amt.to_money("MGA").format(:symbol => false).should == amt
    end
    ("-0.1".."-9.4").each do |amt|
      next if amt[-1].to_i > 4
      amt.to_money("MGA").format(:symbol => false).should == amt
    end
    "1000.0".to_money("MGA").format(:symbol => false).should == "1,000.0"
    "-1000.0".to_money("MGA").format(:symbol => false).should == "-1,000.0"
  end

  specify "Money.format brute force :subunit_to_unit = 10" do
    ("0.0".."9.9").each do |amt|
      amt.to_money("VND").format(:symbol => false).should == amt
    end
    ("-0.1".."-9.9").each do |amt|
      amt.to_money("VND").format(:symbol => false).should == amt
    end
    "1000.0".to_money("VND").format(:symbol => false).should == "1,000.0"
    "-1000.0".to_money("VND").format(:symbol => false).should == "-1,000.0"
  end

  specify "Money.format brute force :subunit_to_unit = 100" do
    ("0.00".."9.99").each do |amt|
      amt.to_money("USD").format(:symbol => false).should == amt
    end
    ("-0.01".."-9.99").each do |amt|
      amt.to_money("USD").format(:symbol => false).should == amt
    end
    "1000.00".to_money("USD").format(:symbol => false).should == "1,000.00"
    "-1000.00".to_money("USD").format(:symbol => false).should == "-1,000.00"
  end

  specify "Money.format brute force :subunit_to_unit = 1000" do
    ("0.000".."9.999").each do |amt|
      amt.to_money("IQD").format(:symbol => false).should == amt
    end
    ("-0.001".."-9.999").each do |amt|
      amt.to_money("IQD").format(:symbol => false).should == amt
    end
    "1000.000".to_money("IQD").format(:symbol => false).should == "1,000.000"
    "-1000.000".to_money("IQD").format(:symbol => false).should == "-1,000.000"
  end

  specify "Money.to_s works" do
    Money.new(10_00).to_s.should == "10.00"
    Money.new(400_08).to_s.should == "400.08"
    Money.new(-237_43).to_s.should == "-237.43"
  end

  specify "Money.to_s should respect :subunit_to_unit currency property" do
    Money.new(10_00, "BHD").to_s.should == "1.000"
    Money.new(10_00, "CNY").to_s.should == "100.0"
  end

  specify "Money.to_s shouldn't have decimal when :subunit_to_unit is 1" do
    Money.new(10_00, "CLP").to_s.should == "1000"
  end

  specify "Money.to_s should work with :subunit_to_unit == 5" do
    Money.new(10_00, "MGA").to_s.should == "200.0"
  end

  specify "Money.to_s should respect :separator" do
    Money.new(10_00, "BRL").to_s.should == "10,00"
  end

  specify "Money.to_f works" do
    Money.new(10_00).to_f.should == 10.0
  end

  specify "Money.to_f should respect :subunit_to_unit currency property" do
    Money.new(10_00, "BHD").to_f.should == 1.0
  end

  specify "#symbol works as documented" do
    currency = Money::Currency.new("EUR")
    currency.should_receive(:symbol).and_return("€")
    Money.empty(currency).symbol.should == "€"

    currency = Money::Currency.new("EUR")
    currency.should_receive(:symbol).and_return(nil)
    Money.empty(currency).symbol.should == "¤"
  end

  {
    :delimiter => { :default => ",", :other => "." },
    :separator => { :default => ".", :other => "," }
  }.each do |method, options|
    describe "##{method}" do
      context "without I18n" do
        it "works as documented" do
          Money.empty("USD").send(method).should == options[:default]
          Money.empty("EUR").send(method).should == options[:default]
          Money.empty("BRL").send(method).should == options[:other]
        end
      end

      if Object.const_defined?("I18n")
        context "with I18n" do
          before :all do
            reset_i18n
            store_number_formats(:en, method => options[:default])
            store_number_formats(:de, method => options[:other])
          end

          it "looks up #{method} for current locale" do
            I18n.locale = :en
            Money.empty("USD").send(method).should == options[:default]
            I18n.locale = :de
            Money.empty("USD").send(method).should == options[:other]
          end

          it "fallbacks to default behaviour for missing translations" do
            I18n.locale = :de
            Money.empty("USD").send(method).should == options[:other]
            I18n.locale = :fr
            Money.empty("USD").send(method).should == options[:default]
          end

          after :all do
            reset_i18n
          end
        end
      else
        puts "can't test ##{method} with I18n because it isn't loaded"
      end
    end
  end

  describe "#format" do
    it "returns the monetary value as a string" do
      Money.ca_dollar(100).format.should == "$1.00"
      Money.new(40008).format.should == "$400.08"
    end

    it "should respect :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").format.should == "ب.د1.000"
    end

    it "doesn't display a decimal when :subunit_to_unit is 1" do
      Money.new(10_00, "CLP").format.should == "$1.000"
    end

    it "respects the delimiter and separator defaults" do
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
      one_thousand["CNY"].should == "¥10,000.0"

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

    specify "#format(:with_currency => true) works as documented" do
      Money.ca_dollar(100).format(:with_currency => true).should == "$1.00 CAD"
      Money.us_dollar(85).format(:with_currency => true).should == "$0.85 USD"
    end

    specify "#format(:no_cents => true) works as documented" do
      Money.ca_dollar(100).format(:no_cents => true).should == "$1"
      Money.ca_dollar(599).format(:no_cents => true).should == "$5"
      Money.ca_dollar(570).format(:no_cents => true, :with_currency => true).should == "$5 CAD"
      Money.ca_dollar(39000).format(:no_cents => true).should == "$390"
    end

    specify "#format(:no_cents => true) should respect :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").format(:no_cents => true).should == "ب.د1"
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
      one["CNY"].should == "¥10.0"

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


  describe "Money.empty" do
    it "Money.empty creates a new Money object of 0 cents" do
      Money.empty.should == Money.new(0)
    end
  end

  describe "Money.ca_dollar" do
    it "creates a new Money object of the given value in CAD" do
      Money.ca_dollar(50).should == Money.new(50, "CAD")
    end
  end

  describe "Money.us_dollar" do
    it "creates a new Money object of the given value in USD" do
      Money.us_dollar(50).should == Money.new(50, "USD")
    end
  end

  describe "Money.euro" do
    it "creates a new Money object of the given value in EUR" do
      Money.euro(50).should == Money.new(50, "EUR")
    end
  end


  describe "Money.new_with_dollars" do
    it "converts given amount to cents" do
      Money.new_with_dollars(1).should == Money.new(100)
      Money.new_with_dollars(1, "USD").should == Money.new(100, "USD")
      Money.new_with_dollars(1, "EUR").should == Money.new(100, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.new_with_dollars(1, "USD").should == Money.new(1_00,  "USD")
      Money.new_with_dollars(1, "TND").should == Money.new(1_000, "TND")
      Money.new_with_dollars(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "should not loose precision" do
      Money.new_with_dollars(1234).cents.should == 1234_00
      Money.new_with_dollars(100.37).cents.should == 100_37
      Money.new_with_dollars(BigDecimal.new('1234')).cents.should == 1234_00
    end

    it "accepts a currency options" do
      m = Money.new_with_dollars(1)
      m.currency.should == Money.default_currency

      m = Money.new_with_dollars(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.new_with_dollars(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end

    it "accepts a bank options" do
      m = Money.new_with_dollars(1)
      m.bank.should == Money.default_bank

      m = Money.new_with_dollars(1, "EUR", bank = Object.new)
      m.bank.should == bank
    end

    it "is associated to the singleton instance of Bank::VariableExchange by default" do
      Money.new_with_dollars(0).bank.should be_equal(Money::Bank::VariableExchange.instance)
    end
  end

  describe "Money.from_string" do
    it "converts given amount to cents" do
      Money.from_string("1").should == Money.new(1_00)
      Money.from_string("1").should == Money.new(1_00, "USD")
      Money.from_string("1", "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_string("1", "USD").should == Money.new(1_00,  "USD")
      Money.from_string("1", "TND").should == Money.new(1_000, "TND")
      Money.from_string("1", "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_string("1")
      m.currency.should == Money.default_currency

      m = Money.from_string("1", Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_string("1", "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe "Money.from_fixnum" do
    it "converts given amount to cents" do
      Money.from_fixnum(1).should == Money.new(1_00)
      Money.from_fixnum(1).should == Money.new(1_00, "USD")
      Money.from_fixnum(1, "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_fixnum(1, "USD").should == Money.new(1_00,  "USD")
      Money.from_fixnum(1, "TND").should == Money.new(1_000, "TND")
      Money.from_fixnum(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_fixnum(1)
      m.currency.should == Money.default_currency

      m = Money.from_fixnum(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_fixnum(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe "Money.from_float" do
    it "converts given amount to cents" do
      Money.from_float(1.2).should == Money.new(1_20)
      Money.from_float(1.2).should == Money.new(1_20, "USD")
      Money.from_float(1.2, "EUR").should == Money.new(1_20, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_float(1.2, "USD").should == Money.new(1_20,  "USD")
      Money.from_float(1.2, "TND").should == Money.new(1_200, "TND")
      Money.from_float(1.2, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_float(1.2)
      m.currency.should == Money.default_currency

      m = Money.from_float(1.2, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_float(1.2, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe "Money.from_bigdecimal" do
    it "converts given amount to cents" do
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00)
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00, "USD")
      Money.from_bigdecimal(BigDecimal.new("1"), "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_bigdecimal(BigDecimal.new("1"), "USD").should == Money.new(1_00,  "USD")
      Money.from_bigdecimal(BigDecimal.new("1"), "TND").should == Money.new(1_000, "TND")
      Money.from_bigdecimal(BigDecimal.new("1"), "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_bigdecimal(BigDecimal.new("1"))
      m.currency.should == Money.default_currency

      m = Money.from_bigdecimal(BigDecimal.new("1"), Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_bigdecimal(BigDecimal.new("1"), "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe "Money.from_numeric" do
    it "converts given amount to cents" do
      Money.from_numeric(1).should == Money.new(1_00)
      Money.from_numeric(1.0).should == Money.new(1_00)
      Money.from_numeric(BigDecimal.new("1")).should == Money.new(1_00)
    end

    it "should raise ArgumentError with unsupported argument" do
      lambda { Money.from_numeric("100") }.should raise_error(ArgumentError)
    end

    it "should optimize workload" do
      Money.should_receive(:from_fixnum).with(1, "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1, "USD").should == Money.new(1_00,  "USD")
      Money.should_receive(:from_bigdecimal).with(BigDecimal.new("1.0"), "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1.0, "USD").should == Money.new(1_00,  "USD")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_numeric(1, "USD").should == Money.new(1_00,  "USD")
      Money.from_numeric(1, "TND").should == Money.new(1_000, "TND")
      Money.from_numeric(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a bank option" do
      Money.from_numeric(1).should == Money.new(1_00)
      Money.from_numeric(1).should == Money.new(1_00, "USD")
      Money.from_numeric(1, "EUR").should == Money.new(1_00, "EUR")
    end

    it "accepts a currency options" do
      m = Money.from_numeric(1)
      m.currency.should == Money.default_currency

      m = Money.from_numeric(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_numeric(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end


  describe "Money.add_rate" do
    it "saves rate into current bank" do
      Money.add_rate("EUR", "USD", 10)
      Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
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
    specify "#<=> compares the two object amounts" do
      (Money.new(1_00, "USD") <=> Money.new(1_00, "USD")).should == 0
      (Money.new(1_00, "USD") <=> Money.new(99, "USD")).should > 0
      (Money.new(1_00, "USD") <=> Money.new(2_00, "USD")).should < 0
    end

    specify "#+ adds other amount to current amount and returns a Money while retaining the currency" do
      (Money.new(10_00, "USD") + Money.new(90, "USD")).should == Money.new(10_90, "USD")
    end

    specify "#- subtracts other amount from current amount and returns a Money while retaining the currency" do
      (Money.new(10_00, "USD") - Money.new(90, "USD")).should == Money.new(9_10, "USD")
    end

    specify "#* should raise ArgumentError" do
      lambda { Money.new(10_00, "USD") * Money.new(2, "USD") }.should raise_error(ArgumentError)
    end

    specify "#/ divides current amount by other amount and returns a Float" do
      (Money.new(10_00, "USD") / Money.new(100_00, "USD")).should == 0.1
    end
  end

  describe "if the other Money object has a different currency" do
    specify "#<=> converts other object amount to current currency, then compares the two object amounts" do
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

    specify "#+ converts other object amount to current currency, then adds other amount to current amount and returns a Money" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") + other).should == Money.new(19_00, "USD")
    end

    specify "#- converts other object amount to current currency, then subtracts other amount from current amount and returns a Money" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") - other).should == Money.new(1_00, "USD")
    end

    specify "#* should raise ArgumentError" do
      lambda { Money.new(10_00, "USD") * Money.new(10, "EUR") }.should raise_error(ArgumentError)
    end

    specify "#/ converts other object amount to current currency, then divides current amount by other amount and returns a Float" do
      other = Money.new(1000, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(100_00, "USD"))
      (Money.new(10_00, "USD") / other).should == 0.1
    end
  end
end
