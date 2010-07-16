$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'money/currency'
require 'money/bank'

describe Money::Bank do
  describe '#new without block' do
    before :each do
      @bank = Money::Bank.new
    end

    describe '#rate_key_for' do
      it 'should accept str/str' do
        lambda{@bank.send(:rate_key_for, 'USD', 'EUR')}.should_not raise_exception
      end

      it 'should accept currency/str' do
        lambda{@bank.send(:rate_key_for, Money::Currency.wrap('USD'), 'EUR')}.should_not raise_exception
      end

      it 'should accept str/currency' do
        lambda{@bank.send(:rate_key_for, 'USD', Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should accept currency/currency' do
        lambda{@bank.send(:rate_key_for, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should return a hashkey based on the passed arguments' do
        @bank.send(:rate_key_for, 'USD', 'EUR').should == 'USD_TO_EUR'
        @bank.send(:rate_key_for, Money::Currency.wrap('USD'), 'EUR').should == 'USD_TO_EUR'
        @bank.send(:rate_key_for, 'USD', Money::Currency.wrap('EUR')).should == 'USD_TO_EUR'
        @bank.send(:rate_key_for, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR')).should == 'USD_TO_EUR'
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is passed' do
        lambda{@bank.send(:rate_key_for, 'AAA', 'BBB')}.should raise_exception(Money::Currency::UnknownCurrency)
      end
    end

    describe '#set_rate' do
      it 'should set a rate' do
        @bank.send(:set_rate, 'USD', 'EUR', 1.25)
        @bank.instance_variable_get(:@rates)['USD_TO_EUR'].should == 1.25
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is passed' do
        lambda{@bank.send(:set_rate, 'AAA', 'BBB', 1.25)}.should raise_exception(Money::Currency::UnknownCurrency)
      end
    end

    describe '#get_rate' do
      it 'should return a rate' do
        @bank.send(:set_rate, 'USD', 'EUR', 1.25)
        @bank.send(:get_rate, 'USD', 'EUR').should == 1.25
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is requested' do
        lambda{@bank.send(:get_rate, 'AAA', 'BBB')}.should raise_exception(Money::Currency::UnknownCurrency)
      end
    end

    describe '#same_currency?' do
      it 'should accept str/str' do
        lambda{@bank.send(:same_currency?, 'USD', 'EUR')}.should_not raise_exception
      end

      it 'should accept currency/str' do
        lambda{@bank.send(:same_currency?, Money::Currency.wrap('USD'), 'EUR')}.should_not raise_exception
      end

      it 'should accept str/currency' do
        lambda{@bank.send(:same_currency?, 'USD', Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should accept currency/currency' do
        lambda{@bank.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should return `true` when currencies match' do
        @bank.send(:same_currency?, 'USD', 'USD').should == true
        @bank.send(:same_currency?, Money::Currency.wrap('USD'), 'USD').should == true
        @bank.send(:same_currency?, 'USD', Money::Currency.wrap('USD')).should == true
        @bank.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('USD')).should == true
      end

      it 'should return `false` when currencies do not match' do
        @bank.send(:same_currency?, 'USD', 'EUR').should == false
        @bank.send(:same_currency?, Money::Currency.wrap('USD'), 'EUR').should == false
        @bank.send(:same_currency?, 'USD', Money::Currency.wrap('EUR')).should == false
        @bank.send(:same_currency?, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR')).should == false
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is passed' do
        lambda{@bank.send(:same_currency?, 'AAA', 'BBB')}.should raise_exception(Money::Currency::UnknownCurrency)
      end
    end

    describe '#exchange' do
      before :each do
        @bank.send(:set_rate, 'USD', 'EUR', 1.33)
      end

      it 'should accept str/str' do
        lambda{@bank.exchange(100, 'USD', 'EUR')}.should_not raise_exception
      end

      it 'should accept currency/str' do
        lambda{@bank.exchange(100, Money::Currency.wrap('USD'), 'EUR')}.should_not raise_exception
      end

      it 'should accept str/currency' do
        lambda{@bank.exchange(100, 'USD', Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should accept currency/currency' do
        lambda{@bank.exchange(100, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should exchange one currency to another' do
        @bank.exchange(100, 'USD', 'EUR').should == 133
      end

      it 'should truncate extra digits' do
        @bank.exchange(10, 'USD', 'EUR').should == 13
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is requested' do
        lambda{@bank.exchange(100, 'AAA', 'BBB')}.should raise_exception(Money::Currency::UnknownCurrency)
      end

      it 'should raise an UnknownRate exception when an unknown rate is requested' do
        lambda{@bank.exchange(100, 'USD', 'JPY')}.should raise_exception(Money::Bank::UnknownRate)
      end

      it 'should accept a custom truncation method' do
        proc = Proc.new{|n| n.ceil}
        @bank.exchange(10, 'USD', 'EUR', &proc).should == 14
      end
    end

    describe '#exchange_with' do
      before :each do
        @bank.send(:set_rate, 'USD', 'EUR', 1.33)
      end

      it 'should accept str' do
        lambda{@bank.exchange_with(Money.new(100, 'USD'), 'EUR')}.should_not raise_exception
      end

      it 'should accept currency' do
        lambda{@bank.exchange_with(Money.new(100, 'USD'), Money::Currency.wrap('EUR'))}.should_not raise_exception
      end

      it 'should exchange one currency to another' do
        @bank.exchange_with(Money.new(100, 'USD'), 'EUR').should == Money.new(133, 'EUR')
      end

      it 'should truncate extra digits' do
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR').should == Money.new(13, 'EUR')
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is requested' do
        lambda{@bank.exchange_with(Money.new(100, 'USD'), 'BBB')}.should raise_exception(Money::Currency::UnknownCurrency)
      end

      it 'should raise an UnknownRate exception when an unknown rate is requested' do
        lambda{@bank.exchange_with(Money.new(100, 'USD'), 'JPY')}.should raise_exception(Money::Bank::UnknownRate)
      end

      it 'should accept a custom truncation method' do
        proc = Proc.new{|n| n.ceil}
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc).should == Money.new(14, 'EUR')
      end
    end
  end

  describe '#new with &block' do
    before :each do
      proc = Proc.new{|n| n.ceil}
      @bank = Money::Bank.new(&proc)
      @bank.send(:set_rate, 'USD', 'EUR', 1.33)
    end

    describe '#exchange' do
      it 'should use a stored truncation method' do
        @bank.exchange(10, 'USD', 'EUR').should == 14
      end

      it 'should use a custom truncation method over a stored one' do
        proc = Proc.new{|n| n.ceil+1}
        @bank.exchange(10, 'USD', 'EUR', &proc).should == 15
      end
    end

    describe '#exchange_with' do
      it 'should use a stored truncation method' do
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR').should == Money.new(14, 'EUR')
      end

      it 'should use a custom truncation method over a stored one' do
        proc = Proc.new{|n| n.ceil+1}
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc).should == Money.new(15, 'EUR')
      end
    end
  end
end
