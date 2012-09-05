require 'spec_helper'

describe Money::Bank::Base do

  describe ".instance" do
    it "is local to one class" do
      klass = Money::Bank::Base
      subclass = Class.new(Money::Bank::Base)
      klass.instance.should_not == subclass.instance
    end
  end

  describe "#initialize" do
    it "accepts a block and stores @rounding_method" do
      proc = Proc.new { |n| n.ceil }
      bank = Money::Bank::Base.new(&proc)
      bank.rounding_method.should == proc
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
      bank.setup_called.should == true
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
      subject.send(:same_currency?, 'USD', 'USD').should be_true
      subject.send(:same_currency?, Money::Currency.wrap('USD'), 'USD').should be_true
      subject.send(:same_currency?, 'USD', Money::Currency.wrap('USD')).should be_true
      subject.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('USD')).should be_true
    end

    it "returns false when currencies do not match" do
      subject.send(:same_currency?, 'USD', 'EUR').should be_false
      subject.send(:same_currency?, Money::Currency.wrap('USD'), 'EUR').should be_false
      subject.send(:same_currency?, 'USD', Money::Currency.wrap('EUR')).should be_false
      subject.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR')).should be_false
    end

    it "raises an UnknownCurrency exception when an unknown currency is passed" do
      expect { subject.send(:same_currency?, 'AAA', 'BBB') }.to raise_exception(Money::Currency::UnknownCurrency)
    end
  end
end
