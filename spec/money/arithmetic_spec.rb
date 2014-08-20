# encoding: utf-8

require "spec_helper"

describe Money do
  describe "-@" do
    it "changes the sign of a number" do
      expect((- Money.new(0))).to  eq Money.new(0)
      expect((- Money.new(1))).to  eq Money.new(-1)
      expect((- Money.new(-1))).to eq Money.new(1)
    end
  end

  describe "#==" do
    it "returns true if and only if their amount and currency are equal" do
      expect(Money.new(1_00, "USD")).to     eq Money.new(1_00, "USD")
      expect(Money.new(1_00, "USD")).not_to eq Money.new(1_00, "EUR")
      expect(Money.new(1_00, "USD")).not_to eq Money.new(2_00, "USD")
      expect(Money.new(1_00, "USD")).not_to eq Money.new(99_00, "EUR")
    end

    it "returns false if used to compare with an object that doesn't respond to #to_money" do
      expect(Money.new(1_00, "USD")).not_to eq Object.new
      expect(Money.new(1_00, "USD")).not_to eq Class
      expect(Money.new(1_00, "USD")).not_to eq Kernel
      expect(Money.new(1_00, "USD")).not_to eq /foo/
      expect(Money.new(1_00, "USD")).not_to eq nil
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

      expect(Money.new(1_00, "USD")).to     eq klass.new(Money.new(1_00, "USD"))
      expect(Money.new(2_50, "USD")).to     eq klass.new(Money.new(2_50, "USD"))
      expect(Money.new(2_50, "USD")).not_to eq klass.new(Money.new(3_00, "USD"))
      expect(Money.new(1_00, "GBP")).not_to eq klass.new(Money.new(1_00, "USD"))
    end
  end

  describe "#eql?" do
    it "returns true if and only if their amount and currency are equal" do
      expect(Money.new(1_00, "USD").eql?(Money.new(1_00, "USD"))).to  be true
      expect(Money.new(1_00, "USD").eql?(Money.new(1_00, "EUR"))).to  be false
      expect(Money.new(1_00, "USD").eql?(Money.new(2_00, "USD"))).to  be false
      expect(Money.new(1_00, "USD").eql?(Money.new(99_00, "EUR"))).to be false
    end

    it "returns false if used to compare with an object that doesn't respond to #to_money" do
      expect(Money.new(1_00, "USD").eql?(Object.new)).to  be false
      expect(Money.new(1_00, "USD").eql?(Class)).to       be false
      expect(Money.new(1_00, "USD").eql?(Kernel)).to      be false
      expect(Money.new(1_00, "USD").eql?(/foo/)).to       be false
      expect(Money.new(1_00, "USD").eql?(nil)).to         be false
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

      expect(Money.new(1_00, "USD").eql?(klass.new(Money.new(1_00, "USD")))).to be true
      expect(Money.new(2_50, "USD").eql?(klass.new(Money.new(2_50, "USD")))).to be true
      expect(Money.new(2_50, "USD").eql?(klass.new(Money.new(3_00, "USD")))).to be false
      expect(Money.new(1_00, "GBP").eql?(klass.new(Money.new(1_00, "USD")))).to be false
    end
  end

  describe "#<=>" do
    it "compares the two object amounts (same currency)" do
      expect((Money.new(1_00, "USD") <=> Money.new(1_00, "USD"))).to eq 0
      expect((Money.new(1_00, "USD") <=> Money.new(99, "USD"))).to be > 0
      expect((Money.new(1_00, "USD") <=> Money.new(2_00, "USD"))).to be < 0
    end

    it "converts other object amount to current currency, then compares the two object amounts (different currency)" do
      target = Money.new(200_00, "EUR")
      expect(target).to receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(300_00, "USD"))
      expect(Money.new(100_00, "USD") <=> target).to be < 0

      target = Money.new(200_00, "EUR")
      expect(target).to receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(100_00, "USD"))
      expect(Money.new(100_00, "USD") <=> target).to eq 0

      target = Money.new(200_00, "EUR")
      expect(target).to receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(99_00, "USD"))
      expect(Money.new(100_00, "USD") <=> target).to be > 0
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

      expect(Money.new(1_00) <=> klass.new(Money.new(1_00))).to eq 0
      expect(Money.new(1_00) <=> klass.new(Money.new(99))).to be > 0
      expect(Money.new(1_00) <=> klass.new(Money.new(2_00))).to be < 0
    end

    it "raises ArgumentError when used to compare with an object that doesn't respond to #to_money" do
      expected_message = /Comparison .+ failed/
      expect{ Money.new(1_00) <=> Object.new  }.to raise_error(ArgumentError, expected_message)
      expect{ Money.new(1_00) <=> Class       }.to raise_error(ArgumentError, expected_message)
      expect{ Money.new(1_00) <=> Kernel      }.to raise_error(ArgumentError, expected_message)
      expect{ Money.new(1_00) <=> /foo/       }.to raise_error(ArgumentError, expected_message)
    end
  end

  describe "#positive?" do
    it "returns true if the amount is greater than 0" do
      expect(Money.new(1)).to be_positive
    end

    it "returns false if the amount is 0" do
      expect(Money.new(0)).not_to be_positive
    end

    it "returns false if the amount is negative" do
      expect(Money.new(-1)).not_to be_positive
    end
  end

  describe "#negative?" do
    it "returns true if the amount is less than 0" do
      expect(Money.new(-1)).to be_negative
    end

    it "returns false if the amount is 0" do
      expect(Money.new(0)).not_to be_negative
    end

    it "returns false if the amount is greater than 0" do
      expect(Money.new(1)).not_to be_negative
    end
  end

  describe "#+" do
    it "adds other amount to current amount (same currency)" do
      expect(Money.new(10_00, "USD") + Money.new(90, "USD")).to eq Money.new(10_90, "USD")
    end

    it "converts other object amount to current currency and adds other amount to current amount (different currency)" do
      other = Money.new(90, "EUR")
      expect(other).to receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      expect(Money.new(10_00, "USD") + other).to eq Money.new(19_00, "USD")
    end

    it "adds Fixnum 0 to money and returns the same ammount" do
      expect(Money.new(10_00) + 0).to eq Money.new(10_00)
    end
  end

  describe "#-" do
    it "subtracts other amount from current amount (same currency)" do
      expect(Money.new(10_00, "USD") - Money.new(90, "USD")).to eq Money.new(9_10, "USD")
    end

    it "converts other object amount to current currency and subtracts other amount from current amount (different currency)" do
      other = Money.new(90, "EUR")
      expect(other).to receive(:exchange_to).with(Money::Currency.new("USD")).and_return(Money.new(9_00, "USD"))
      expect(Money.new(10_00, "USD") - other).to eq Money.new(1_00, "USD")
    end

    it "subtract Fixnum 0 to money and returns the same ammount" do
      expect(Money.new(10_00) - 0).to eq Money.new(10_00)
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
        expect(t[:a] * t[:b]).to eq t[:c]
      end
    end

    it "does not multiply Money by Money (same currency)" do
      expect { Money.new( 10, :USD) * Money.new( 4, :USD) }.to raise_error(ArgumentError)
    end

    it "does not multiply Money by Money (different currency)" do
      expect { Money.new( 10, :USD) * Money.new( 4, :EUR) }.to raise_error(ArgumentError)
    end

    it "does not multiply Money by an object which is NOT a number" do
      expect { Money.new( 10, :USD) *  'abc' }.to raise_error(ArgumentError)
    end
  end

  describe "#/" do
    it "divides Money by Fixnum and returns Money" do
      ts = [
        {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
        {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3, :USD)},
        {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-3, :USD)},
        {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3, :USD)},
      ]
      ts.each do |t|
        expect(t[:a] / t[:b]).to eq t[:c]
      end
    end

    context 'rounding preference' do
      before do
        allow(Money).to receive(:rounding_mode).and_return(rounding_mode)
      end

      after do
        allow(Money).to receive(:rounding_mode).and_call_original
      end

      context 'ceiling rounding' do
        let(:rounding_mode) { BigDecimal::ROUND_CEILING }
        it "obeys the rounding preference" do
          expect(Money.new(10) / 3).to eq Money.new(4)
        end
      end

      context 'floor rounding' do
        let(:rounding_mode) { BigDecimal::ROUND_FLOOR }
        it "obeys the rounding preference" do
          expect(Money.new(10) / 6).to eq Money.new(1)
        end
      end

      context 'half up rounding' do
        let(:rounding_mode) { BigDecimal::ROUND_HALF_UP }
        it "obeys the rounding preference" do
          expect(Money.new(10) / 4).to eq Money.new(3)
        end
      end

      context 'half down rounding' do
        let(:rounding_mode) { BigDecimal::ROUND_HALF_DOWN }
        it "obeys the rounding preference" do
          expect(Money.new(10) / 4).to eq Money.new(2)
        end
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
        expect(t[:a] / t[:b]).to eq t[:c]
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
        expect(t[:b]).to receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
        expect(t[:a] / t[:b]).to eq t[:c]
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
          expect(t[:a] / t[:b]).to eq t[:c]
        end
      end
    end
  end

  describe "#div" do
    it "divides Money by Fixnum and returns Money" do
      ts = [
          {:a => Money.new( 13, :USD), :b =>  4, :c => Money.new( 3, :USD)},
          {:a => Money.new( 13, :USD), :b => -4, :c => Money.new(-3, :USD)},
          {:a => Money.new(-13, :USD), :b =>  4, :c => Money.new(-3, :USD)},
          {:a => Money.new(-13, :USD), :b => -4, :c => Money.new( 3, :USD)},
      ]
      ts.each do |t|
        expect(t[:a].div(t[:b])).to eq t[:c]
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
        expect(t[:a].div(t[:b])).to eq t[:c]
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
        expect(t[:b]).to receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
        expect(t[:a].div(t[:b])).to eq t[:c]
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
          expect(t[:a].div(t[:b])).to eq t[:c]
        end
      end
    end
  end

  describe "#divmod" do
    it "calculates division and modulo with Fixnum" do
      ts = [
          {:a => Money.new( 13, :USD), :b =>  4, :c => [Money.new( 3, :USD), Money.new( 1, :USD)]},
          {:a => Money.new( 13, :USD), :b => -4, :c => [Money.new(-3, :USD), Money.new(-3, :USD)]},
          {:a => Money.new(-13, :USD), :b =>  4, :c => [Money.new(-3, :USD), Money.new( 3, :USD)]},
          {:a => Money.new(-13, :USD), :b => -4, :c => [Money.new( 3, :USD), Money.new(-1, :USD)]},
      ]
      ts.each do |t|
        expect(t[:a].divmod(t[:b])).to eq t[:c]
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
        expect(t[:a].divmod(t[:b])).to eq t[:c]
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
        expect(t[:b]).to receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
        expect(t[:a].divmod(t[:b])).to eq t[:c]
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
          expect(t[:a].divmod(t[:b])).to eq t[:c]
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
        expect(t[:a].modulo(t[:b])).to eq t[:c]
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
        expect(t[:a].modulo(t[:b])).to eq t[:c]
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
        expect(t[:b]).to receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
        expect(t[:a].modulo(t[:b])).to eq t[:c]
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
        expect(t[:a] % t[:b]).to eq t[:c]
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
        expect(t[:a] % t[:b]).to eq t[:c]
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
        expect(t[:b]).to receive(:exchange_to).once.with(t[:a].currency).and_return(Money.new(t[:b].cents * 2, :USD))
        expect(t[:a] % t[:b]).to eq t[:c]
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
        expect(t[:a].remainder(t[:b])).to eq t[:c]
      end
    end
  end

  describe "#abs" do
    it "returns the absolute value as a new Money object" do
      n = Money.new(-1, :USD)
      expect(n.abs).to eq Money.new( 1, :USD)
      expect(n).to     eq Money.new(-1, :USD)
    end
  end

  describe "#zero?" do
    it "returns whether the amount is 0" do
      expect(Money.new(0, "USD")).to be_zero
      expect(Money.new(0, "EUR")).to be_zero
      expect(Money.new(1, "USD")).not_to be_zero
      expect(Money.new(10, "YEN")).not_to be_zero
      expect(Money.new(-1, "EUR")).not_to be_zero
    end
  end

  describe "#nonzero?" do
    it "returns whether the amount is not 0" do
      expect(Money.new(0, "USD")).not_to be_nonzero
      expect(Money.new(0, "EUR")).not_to be_nonzero
      expect(Money.new(1, "USD")).to be_nonzero
      expect(Money.new(10, "YEN")).to be_nonzero
      expect(Money.new(-1, "EUR")).to be_nonzero
    end

    it "has the same return-value semantics as Numeric#nonzero?" do
      expect(Money.new(0, "USD").nonzero?).to be_nil

      money = Money.new(1, "USD")
      expect(money.nonzero?).to be_equal(money)
    end
  end

  describe "#coerce" do
    it "allows mathematical operations by coercing arguments" do
      result = 2 * Money.new(4, 'USD')
      expect(result).to eq Money.new(8, 'USD')
    end
  end
end
