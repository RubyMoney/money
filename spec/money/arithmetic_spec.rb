# encoding: utf-8

require "spec_helper"

describe Money do
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

end
