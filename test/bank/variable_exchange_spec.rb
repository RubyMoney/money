$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'money/bank/variable_exchange'

describe Money::Bank::VariableExchange do

  describe '#new without block' do
    before :each do
      @bank = Money::Bank::VariableExchange.new
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

      it 'should round the exchanged result down' do
        @bank.add_rate("USD", "EUR", 0.788332676)
        @bank.add_rate("EUR", "YEN", 122.631477)
        @bank.exchange(10_00, "USD", "EUR").should == 788
        @bank.exchange(500_00, "EUR", "YEN").should == 6131573
      end

      it 'should accept a custom truncation method' do
        proc = Proc.new { |n| n.ceil }
        @bank.exchange(10, 'USD', 'EUR', &proc).should == 14
      end


      context 'sterling to euros using a rate of 1.39' do
        it 'returns the correct amount' do
          @bank.add_rate('GBP', 'EUR', 1.38)
          @bank.exchange(10000, 'GBP', 'EUR').should == 13800
        end
      end

      context 'dollars to euros using a rate of 0.86' do
        it 'returns the correct amount' do
          @bank.add_rate('USD', 'EUR', 0.86)
          @bank.exchange(10000, 'USD', 'EUR').should == 8600
        end
      end

      context 'TND to USD using a rate of 0.67138' do
        it 'returns the correct amount' do
          @bank.add_rate('TND', 'USD', 0.67138)
          @bank.exchange(1000, 'TND', 'USD').should == 67
        end
      end

      context 'USD to TND using a rate of 1.32862' do
        it 'returns the correct amount' do
          @bank.add_rate('USD', 'TND', 1.32862)
          @bank.exchange(1000, 'USD', 'TND').should == 13286
        end
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

      #it 'should round the exchanged result down' do
      #  @bank.add_rate("USD", "EUR", 0.788332676)
      #  @bank.add_rate("EUR", "YEN", 122.631477)
      #  @bank.exchange_with(Money.new(10_00,  "USD"), "EUR").should == Money.new(788, "EUR")
      #  @bank.exchange_with(Money.new(500_00, "EUR"), "YEN").should == Money.new(6131573, "YEN")
      #end

      it 'should accept a custom truncation method' do
        proc = Proc.new { |n| n.ceil }
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc).should == Money.new(14, 'EUR')
      end
    end

    describe "#add_rate" do
      it "should add rates correctly" do
        @bank.add_rate("USD", "EUR", 0.788332676)
        @bank.add_rate("EUR", "YEN", 122.631477)

        @bank.instance_variable_get(:@rates)['USD_TO_EUR'].should == 0.788332676
        @bank.instance_variable_get(:@rates)['EUR_TO_JPY'].should == 122.631477
      end

      it "should treat currency names case-insensitively" do
        @bank.add_rate("usd", "eur", 1)
        @bank.instance_variable_get(:@rates)['USD_TO_EUR'].should == 1
      end
    end

    describe '#set_rate' do
      it 'should set a rate' do
        @bank.set_rate('USD', 'EUR', 1.25)
        @bank.instance_variable_get(:@rates)['USD_TO_EUR'].should == 1.25
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is passed' do
        lambda{ @bank.set_rate('AAA', 'BBB', 1.25) }.should raise_exception(Money::Currency::UnknownCurrency)
      end
    end

    describe '#get_rate' do
      it 'should return a rate' do
        @bank.set_rate('USD', 'EUR', 1.25)
        @bank.get_rate('USD', 'EUR').should == 1.25
      end

      it 'should raise an UnknownCurrency exception when an unknown currency is requested' do
        lambda{ @bank.get_rate('AAA', 'BBB') }.should raise_exception(Money::Currency::UnknownCurrency)
      end
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

  end


  describe '#new with &block' do
    before :each do
      proc = Proc.new { |n| n.ceil }
      @bank = Money::Bank::VariableExchange.new(&proc)
      @bank.add_rate('USD', 'EUR', 1.33)
    end

    describe '#exchange' do
      it 'should use a stored truncation method' do
        @bank.exchange(10, 'USD', 'EUR').should == 14
      end

      it 'should use a custom truncation method over a stored one' do
        proc = Proc.new { |n| n.ceil + 1 }
        @bank.exchange(10, 'USD', 'EUR', &proc).should == 15
      end
    end

    describe '#exchange_with' do
      it 'should use a stored truncation method' do
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR').should == Money.new(14, 'EUR')
      end

      it 'should use a custom truncation method over a stored one' do
        proc = Proc.new { |n| n.ceil + 1 }
        @bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc).should == Money.new(15, 'EUR')
      end
    end
  end

end
