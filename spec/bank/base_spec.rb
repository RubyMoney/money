require 'spec_helper'

describe Money::Bank::Base do

  describe ".instance" do
    it "is local to one class" do
      klass = Money::Bank::Base
      subclass = Class.new(Money::Bank::Base)
      expect(klass.instance).not_to eq subclass.instance
    end
  end

  describe "#initialize" do
    it "accepts a block and stores @rounding_method" do
      proc = Proc.new { |n| n.ceil }
      bank = Money::Bank::Base.new(&proc)
      expect(bank.rounding_method).to eq proc
    end
  end

  describe "#setup" do
    it "calls #setup after #initialize" do
      class MyBank < Money::Bank::Base
        attr_reader :setup_called

        def setup
          @setup_called = true
        end
      end

      bank = MyBank.new
      expect(bank.setup_called).to eq true
    end
  end

  describe "#exchange_with" do
    it "is not implemented" do
      expect { subject.exchange_with(Money.new(100, 'USD'), 'EUR') }.to raise_exception(NotImplementedError)
    end
  end

  describe "#same_currency?" do
    it "accepts str/str" do
      expect { subject.send(:same_currency?, 'USD', 'EUR') }.to_not raise_exception
    end

    it "accepts currency/str" do
      expect { subject.send(:same_currency?, Money::Currency.wrap('USD'), 'EUR') }.to_not raise_exception
    end

    it "accepts str/currency" do
      expect { subject.send(:same_currency?, 'USD', Money::Currency.wrap('EUR')) }.to_not raise_exception
    end

    it "accepts currency/currency" do
      expect { subject.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR')) }.to_not raise_exception
    end

    it "returns true when currencies match" do
      expect(subject.send(:same_currency?, 'USD', 'USD')).to be true
      expect(subject.send(:same_currency?, Money::Currency.wrap('USD'), 'USD')).to be true
      expect(subject.send(:same_currency?, 'USD', Money::Currency.wrap('USD'))).to be true
      expect(subject.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('USD'))).to be true
    end

    it "returns false when currencies do not match" do
      expect(subject.send(:same_currency?, 'USD', 'EUR')).to be false
      expect(subject.send(:same_currency?, Money::Currency.wrap('USD'), 'EUR')).to be false
      expect(subject.send(:same_currency?, 'USD', Money::Currency.wrap('EUR'))).to be false
      expect(subject.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))).to be false
    end

    it "raises an UnknownCurrency exception when an unknown currency is passed" do
      expect { subject.send(:same_currency?, 'AAA', 'BBB') }.to raise_exception(Money::Currency::UnknownCurrency)
    end
  end
end
