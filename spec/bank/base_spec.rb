require "spec_helper"

describe Money::Bank::Base do
  before :each do
    @bank = Money::Bank::Base.new
  end

  describe '#new with &block' do
    it 'should store @rounding_method' do
      proc = Proc.new{|n| n.ceil}
      bank = Money::Bank::Base.new(&proc)
      bank.rounding_method.should == proc
    end
  end

  describe '#setup' do
    it 'should call #setup after #initialize' do
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

  describe '#exchange_with' do
    it 'should raise NotImplementedError' do
      lambda { @bank.exchange_with(Money.new(100, 'USD'), 'EUR') }.should raise_exception(NotImplementedError)
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
end
