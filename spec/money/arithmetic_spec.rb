# encoding: utf-8

require "spec_helper"

describe Money do
  describe "-@" do
    it "changes the sign of a number" do
      (- Money.new(0)).should == Money.new(0)
      (- Money.new(1)).should == Money.new(-1)
      (- Money.new(-1)).should == Money.new(1)
    end
  end

  describe "#==" do
    it "returns true if and only if their amount and currency are equal" do
      Money.new(1_00, "USD").should == Money.new(1_00, "USD")
      Money.new(1_00, "USD").should_not == Money.new(1_00, "EUR")
      Money.new(1_00, "USD").should_not == Money.new(2_00, "USD")
      Money.new(1_00, "USD").should_not == Money.new(99_00, "EUR")
    end

    it "returns false if used to compare with an object that doesn't respond to #to_money" do
      Money.new(1_00, "USD").should_not == Object.new
      Money.new(1_00, "USD").should_not == Class
      Money.new(1_00, "USD").should_not == Kernel
      Money.new(1_00, "USD").should_not == /foo/
      Money.new(1_00, "USD").should_not == nil
    end

    it "can be used to compare with a String money value" do
      Money.new(1_00, "USD").should == "1.00"
      Money.new(1_00, "USD").should_not == "2.00"
      Money.new(1_00, "GBP").should_not == "1.00"
    end

    it "can be used to compare with a Numeric money value" do
      Money.new(1_00, "USD").should == 1
      Money.new(1_57, "USD").should == 1.57
      Money.new(1_00, "USD").should_not == 2
      Money.new(1_00, "GBP").should_not == 1
    end

    it "can be used to compare with an object that responds to #to_money" do
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
  end

  describe "#eql?" do
    it "returns true if and only if their amount and currency are equal" do
      Money.new(1_00, "USD").eql?(Money.new(1_00, "USD")).should be true
      Money.new(1_00, "USD").eql?(Money.new(1_00, "EUR")).should be false
      Money.new(1_00, "USD").eql?(Money.new(2_00, "USD")).should be false
      Money.new(1_00, "USD").eql?(Money.new(99_00, "EUR")).should be false
    end

    it "returns false if used to compare with an object that doesn't respond to #to_money" do
      Money.new(1_00, "USD").eql?(Object.new).should be false
      Money.new(1_00, "USD").eql?(Class).should be false
      Money.new(1_00, "USD").eql?(Kernel).should be false
      Money.new(1_00, "USD").eql?(/foo/).should be false
      Money.new(1_00, "USD").eql?(nil).should be false
    end

    it "can be used to compare with a String money value" do
      Money.new(1_00, "USD").eql?("1.00").should be true
      Money.new(1_00, "USD").eql?("2.00").should be false
      Money.new(1_00, "GBP").eql?("1.00").should be false
    end

    it "can be used to compare with a Numeric money value" do
      Money.new(1_00, "USD").eql?(1).should be true
      Money.new(1_57, "USD").eql?(1.57).should be true
      Money.new(1_00, "USD").eql?(2).should be false
      Money.new(1_00, "GBP").eql?(1).should be false
    end

    it "can be used to compare with an object that responds to #to_money" do
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
  end

  describe "#<=>" do
    it "compares the two object amounts (same currency)" do
      (Money.new(1_00, "USD") <=> Money.new(1_00, "USD")).should == 0
      (Money.new(1_00, "USD") <=> Money.new(99, "USD")).should > 0
      (Money.new(1_00, "USD") <=> Money.new(2_00, "USD")).should < 0
    end

    it "converts other object amount to current currency, then compares the two object amounts (different currency)" do
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

    it "can be used to compare with a String money value" do
      (Money.new(1_00) <=> "1.00").should == 0
      (Money.new(1_00) <=> ".99").should > 0
      (Money.new(1_00) <=> "2.00").should < 0
    end

    it "can be used to compare with a Numeric money value" do
      (Money.new(1_00) <=> 1).should == 0
      (Money.new(1_00) <=> 0.99).should > 0
      (Money.new(1_00) <=> 2.00).should < 0
    end

    it "can be used to compare with an object that responds to #to_money" do
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

    it "raises ArgumentError when used to compare with an object that doesn't respond to #to_money" do
      expected_message = /Comparison .+ failed/
      lambda{ Money.new(1_00) <=> Object.new  }.should raise_error(ArgumentError, expected_message)
      lambda{ Money.new(1_00) <=> Class       }.should raise_error(ArgumentError, expected_message)
      lambda{ Money.new(1_00) <=> Kernel      }.should raise_error(ArgumentError, expected_message)
      lambda{ Money.new(1_00) <=> /foo/       }.should raise_error(ArgumentError, expected_message)
    end
  end

  describe "#positive?" do
    it "returns true if the amount is greater than 0" do
      Money.new(1).should be_positive
    end

    it "returns false if the amount is 0" do
      Money.new(0).should_not be_positive
    end

    it "returns false if the amount is negative" do
      Money.new(-1).should_not be_positive
    end
  end

  describe "#negative?" do
    it "returns true if the amount is less than 0" do
      Money.new(-1).should be_negative
    end

    it "returns false if the amount is 0" do
      Money.new(0).should_not be_negative
    end

    it "returns false if the amount is greater than 0" do
      Money.new(1).should_not be_negative
    end
  end

  describe "#+" do
    it "adds other amount to current amount (same currency)" do
      (Money.new(10_00, "USD") + Money.new(90, "USD")).should == Money.new(10_90, "USD")
    end

    it "converts other object amount to current currency and adds other amount to current amount (different currency)" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") + other).should == Money.new(19_00, "USD")
    end
  end

  describe "#-" do
    it "subtracts other amount from current amount (same currency)" do
      (Money.new(10_00, "USD") - Money.new(90, "USD")).should == Money.new(9_10, "USD")
    end

    it "converts other object amount to current currency and subtracts other amount from current amount (different currency)" do
      other = Money.new(90, "EUR")
      other.should_receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      (Money.new(10_00, "USD") - other).should == Money.new(1_00, "USD")
    end
  end

  describe "#*" do
    it "multiplies Money by Fixnum and returns Money" do
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

    it "does not multiply Money by Money (same currency)" do
      lambda { Money.new( 10, :USD) * Money.new( 4, :USD) }.should raise_error(ArgumentError)
    end

    it "does not multiply Money by Money (different currency)" do
      lambda { Money.new( 10, :USD) * Money.new( 4, :EUR) }.should raise_error(ArgumentError)
    end
  end

  describe "#/" do
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

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "uses BigDecimal division" do
        ts = [
          {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3.25, :USD)},
          {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3.25, :USD)},
          {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-3.25, :USD)},
          {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3.25, :USD)},
        ]
        ts.each do |t|
          (t[:a] / t[:b]).should == t[:c]
        end
      end
    end
  end

  describe "#div" do
    it "divides Money by Fixnum and returns Money" do
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

    it "divides Money by Money (same currency) and returns Float" do
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

    it "divides Money by Money (different currency) and returns Float" do
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

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "uses BigDecimal division" do
        ts = [
          {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3.25, :USD)},
          {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3.25, :USD)},
          {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-3.25, :USD)},
          {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3.25, :USD)},
        ]
        ts.each do |t|
          t[:a].div(t[:b]).should == t[:c]
        end
      end
    end
  end

  describe "#divmod" do
    it "calculates division and modulo with Fixnum" do
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

    it "calculates division and modulo with Money (same currency)" do
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

    it "calculates division and modulo with Money (different currency)" do
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

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "uses BigDecimal division" do
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
    end
  end

  describe "#modulo" do
    it "calculates modulo with Fixnum" do
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

    it "calculates modulo with Money (same currency)" do
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

    it "calculates modulo with Money (different currency)" do
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
  end

  describe "#%" do
    it "calculates modulo with Fixnum" do
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

    it "calculates modulo with Money (same currency)" do
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

    it "calculates modulo with Money (different currency)" do
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
  end

  describe "#remainder" do
    it "calculates remainder with Fixnum" do
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

    it "calculates remainder with Money (same currency)" do
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

    it "calculates remainder with Money (different currency)" do
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
  end

  describe "#abs" do
    it "returns the absolute value as a new Money object" do
      n = Money.new(-1, :USD)
      n.abs.should == Money.new( 1, :USD)
      n.should     == Money.new(-1, :USD)
    end
  end

  describe "#zero?" do
    it "returns whether the amount is 0" do
      Money.new(0, "USD").should be_zero
      Money.new(0, "EUR").should be_zero
      Money.new(1, "USD").should_not be_zero
      Money.new(10, "YEN").should_not be_zero
      Money.new(-1, "EUR").should_not be_zero
    end
  end

  describe "#nonzero?" do
    it "returns whether the amount is not 0" do
      Money.new(0, "USD").should_not be_nonzero
      Money.new(0, "EUR").should_not be_nonzero
      Money.new(1, "USD").should be_nonzero
      Money.new(10, "YEN").should be_nonzero
      Money.new(-1, "EUR").should be_nonzero
    end

    it "has the same return-value semantics as Numeric#nonzero?" do
      Money.new(0, "USD").nonzero?.should be_nil

      money = Money.new(1, "USD")
      money.nonzero?.should be_equal(money)
    end
  end
end
