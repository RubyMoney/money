require "spec_helper"
require "json"
require "yaml"

describe Money::Bank::VariableExchange do

  describe '#new without block' do
    before :each do
      @bank = Money::Bank::VariableExchange.new
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

    describe '#export_rates' do
      before :each do
        @bank.set_rate('USD', 'EUR', 1.25)
        @bank.set_rate('USD', 'JPY', 2.55)

        @rates = {"USD_TO_EUR"=>1.25,"USD_TO_JPY"=>2.55}
      end

      describe 'with format == :json' do
        it 'should return rates formatted as json' do
          json = @bank.export_rates(:json)
          JSON.load(json).should == @rates
        end
      end

      describe 'with format == :ruby' do
        it 'should return rates formatted as ruby objects' do
          Marshal.load(@bank.export_rates(:ruby)).should == @rates
        end
      end

      describe 'with format == :yaml' do
        it 'should return rates formatted as yaml' do
          yaml = @bank.export_rates(:yaml)
          YAML.load(yaml).should == @rates
        end
      end

      describe 'with unknown format' do
        it 'should raise `UnknownRateFormat`' do
          lambda{@bank.export_rates(:foo)}.should raise_error Money::Bank::UnknownRateFormat
        end
      end

      describe 'with :file provided' do
        it 'should write rates to file' do
          f = mock('IO')
          File.should_receive(:open).with('null', 'w').and_return(f)
          f.should_receive(:write).with(@rates.to_json)

          @bank.export_rates(:json, 'null')
        end
      end
    end

    describe '#import_rates' do
      describe 'with format == :json' do
        it 'should load the rates provided' do
          s = '{"USD_TO_EUR":1.25,"USD_TO_JPY":2.55}'
          @bank.import_rates(:json, s)
          @bank.get_rate('USD', 'EUR').should == 1.25
          @bank.get_rate('USD', 'JPY').should == 2.55
        end
      end

      describe 'with format == :ruby' do
        it 'should load the rates provided' do
          s = Marshal.dump({"USD_TO_EUR"=>1.25,"USD_TO_JPY"=>2.55})
          @bank.import_rates(:ruby, s)
          @bank.get_rate('USD', 'EUR').should == 1.25
          @bank.get_rate('USD', 'JPY').should == 2.55
        end
      end

      describe 'with format == :yaml' do
        it 'should load the rates provided' do
          s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
          @bank.import_rates(:yaml, s)
          @bank.get_rate('USD', 'EUR').should == 1.25
          @bank.get_rate('USD', 'JPY').should == 2.55
        end
      end

      describe 'with unknown format' do
        it 'should raise `UnknownRateFormat`' do
          lambda{@bank.import_rates(:foo, "")}.should raise_error Money::Bank::UnknownRateFormat
        end
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

  describe "#marshal_dump" do
    before :each do
      @bank = Money::Bank::VariableExchange.new
    end

    it 'should not raise an error' do
      lambda{Marshal.dump(@bank)}.should_not raise_error
    end

    it 'should work with Marshal.load' do
      b = Marshal.load(Marshal.dump(@bank))

      b.rates.should           == @bank.rates
      b.rounding_method.should == @bank.rounding_method
    end
  end
end
