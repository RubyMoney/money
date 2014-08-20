require 'spec_helper'
require 'json'
require 'yaml'

describe Money::Bank::VariableExchange do

  describe "#initialize" do
    context "without &block" do
      let(:bank) {
        Money::Bank::VariableExchange.new.tap do |bank|
          bank.add_rate('USD', 'EUR', 1.33)
        end
      }

      describe "#exchange_with" do
        it "accepts str" do
          expect { bank.exchange_with(Money.new(100, 'USD'), 'EUR') }.to_not raise_exception
        end

        it "accepts currency" do
          expect { bank.exchange_with(Money.new(100, 'USD'), Money::Currency.wrap('EUR')) }.to_not raise_exception
        end

        it "exchanges one currency to another" do
          expect(bank.exchange_with(Money.new(100, 'USD'), 'EUR')).to eq Money.new(133, 'EUR')
        end

        it "truncates extra digits" do
          expect(bank.exchange_with(Money.new(10, 'USD'), 'EUR')).to eq Money.new(13, 'EUR')
        end

        it "raises an UnknownCurrency exception when an unknown currency is requested" do
          expect { bank.exchange_with(Money.new(100, 'USD'), 'BBB') }.to raise_exception(Money::Currency::UnknownCurrency)
        end

        it "raises an UnknownRate exception when an unknown rate is requested" do
          expect { bank.exchange_with(Money.new(100, 'USD'), 'JPY') }.to raise_exception(Money::Bank::UnknownRate)
        end

        #it "rounds the exchanged result down" do
        #  bank.add_rate("USD", "EUR", 0.788332676)
        #  bank.add_rate("EUR", "YEN", 122.631477)
        #  expect(bank.exchange_with(Money.new(10_00,  "USD"), "EUR")).to eq Money.new(788, "EUR")
        #  expect(bank.exchange_with(Money.new(500_00, "EUR"), "YEN")).to eq Money.new(6131573, "YEN")
        #end

        it "accepts a custom truncation method" do
          proc = Proc.new { |n| n.ceil }
          expect(bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc)).to eq Money.new(14, 'EUR')
        end
      end
    end

    context "with &block" do
      let(:bank) {
        proc = Proc.new { |n| n.ceil }
        Money::Bank::VariableExchange.new(&proc).tap do |bank|
          bank.add_rate('USD', 'EUR', 1.33)
        end
      }

      describe "#exchange_with" do
        it "uses the stored truncation method" do
          expect(bank.exchange_with(Money.new(10, 'USD'), 'EUR')).to eq Money.new(14, 'EUR')
        end

        it "accepts a custom truncation method" do
          proc = Proc.new { |n| n.ceil + 1 }
          expect(bank.exchange_with(Money.new(10, 'USD'), 'EUR', &proc)).to eq Money.new(15, 'EUR')
        end
      end
    end
  end

  describe "#add_rate" do
    it "adds rates correctly" do
      subject.add_rate("USD", "EUR", 0.788332676)
      subject.add_rate("EUR", "YEN", 122.631477)

      expect(subject.instance_variable_get(:@rates)['USD_TO_EUR']).to eq 0.788332676
      expect(subject.instance_variable_get(:@rates)['EUR_TO_JPY']).to eq 122.631477
    end

    it "treats currency names case-insensitively" do
      subject.add_rate("usd", "eur", 1)
      expect(subject.instance_variable_get(:@rates)['USD_TO_EUR']).to eq 1
    end
  end

  describe "#set_rate" do
    it "sets a rate" do
      subject.set_rate('USD', 'EUR', 1.25)
      expect(subject.instance_variable_get(:@rates)['USD_TO_EUR']).to eq 1.25
    end

    it "raises an UnknownCurrency exception when an unknown currency is passed" do
      expect { subject.set_rate('AAA', 'BBB', 1.25) }.to raise_exception(Money::Currency::UnknownCurrency)
    end

    it "uses a mutex by default" do
      expect(subject.instance_variable_get(:@mutex)).to receive(:synchronize)
      subject.set_rate('USD', 'EUR', 1.25)
    end

    it "doesn't use mutex if requested not to" do
      expect(subject.instance_variable_get(:@mutex)).not_to receive(:synchronize)
      subject.set_rate('USD', 'EUR', 1.25, :without_mutex => true)
    end
  end

  describe "#get_rate" do
    it "returns a rate" do
      subject.set_rate('USD', 'EUR', 1.25)
      expect(subject.get_rate('USD', 'EUR')).to eq 1.25
    end

    it "raises an UnknownCurrency exception when an unknown currency is passed" do
      expect { subject.get_rate('AAA', 'BBB') }.to raise_exception(Money::Currency::UnknownCurrency)
    end

    it "uses a mutex by default" do
      expect(subject.instance_variable_get(:@mutex)).to receive(:synchronize)
      subject.get_rate('USD', 'EUR')
    end

    it "doesn't use mutex if requested not to" do
      expect(subject.instance_variable_get(:@mutex)).not_to receive(:synchronize)
      subject.get_rate('USD', 'EUR', :without_mutex => true)
    end
  end

  describe "#export_rates" do
    before :each do
      subject.set_rate('USD', 'EUR', 1.25)
      subject.set_rate('USD', 'JPY', 2.55)

      @rates = { "USD_TO_EUR" => 1.25, "USD_TO_JPY" => 2.55 }
    end

    context "with format == :json" do
      it "should return rates formatted as json" do
        json = subject.export_rates(:json)
        expect(JSON.load(json)).to eq @rates
      end
    end

    context "with format == :ruby" do
      it "should return rates formatted as ruby objects" do
        expect(Marshal.load(subject.export_rates(:ruby))).to eq @rates
      end
    end

    context "with format == :yaml" do
      it "should return rates formatted as yaml" do
        yaml = subject.export_rates(:yaml)
        expect(YAML.load(yaml)).to eq @rates
      end
    end

    context "with unknown format" do
      it "raises Money::Bank::UnknownRateFormat" do
        expect { subject.export_rates(:foo)}.to raise_error Money::Bank::UnknownRateFormat
      end
    end

    context "with :file provided" do
      it "writes rates to file" do
        f = double('IO')
        expect(File).to receive(:open).with('null', 'w').and_yield(f)
        expect(f).to receive(:write).with(JSON.dump(@rates))

        subject.export_rates(:json, 'null')
      end
    end

    it "uses a mutex by default" do
      expect(subject.instance_variable_get(:@mutex)).to receive(:synchronize)
      subject.export_rates(:yaml)
    end

    it "doesn't use mutex if requested not to" do
      expect(subject.instance_variable_get(:@mutex)).not_to receive(:synchronize)
      subject.export_rates(:yaml, nil, :without_mutex => true)
    end
  end

  describe "#import_rates" do
    context "with format == :json" do
      it "loads the rates provided" do
        s = '{"USD_TO_EUR":1.25,"USD_TO_JPY":2.55}'
        subject.import_rates(:json, s)
        expect(subject.get_rate('USD', 'EUR')).to eq 1.25
        expect(subject.get_rate('USD', 'JPY')).to eq 2.55
      end
    end

    context "with format == :ruby" do
      it "loads the rates provided" do
        s = Marshal.dump({"USD_TO_EUR"=>1.25,"USD_TO_JPY"=>2.55})
        subject.import_rates(:ruby, s)
        expect(subject.get_rate('USD', 'EUR')).to eq 1.25
        expect(subject.get_rate('USD', 'JPY')).to eq 2.55
      end
    end

    context "with format == :yaml" do
      it "loads the rates provided" do
        s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
        subject.import_rates(:yaml, s)
        expect(subject.get_rate('USD', 'EUR')).to eq 1.25
        expect(subject.get_rate('USD', 'JPY')).to eq 2.55
      end
    end

    context "with unknown format" do
      it "raises Money::Bank::UnknownRateFormat" do
        expect { subject.import_rates(:foo, "")}.to raise_error Money::Bank::UnknownRateFormat
      end
    end

    it "uses a mutex by default" do
      expect(subject.instance_variable_get(:@mutex)).to receive(:synchronize)
      s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
      subject.import_rates(:yaml, s)
    end

    it "doesn't use mutex if requested not to" do
      expect(subject.instance_variable_get(:@mutex)).not_to receive(:synchronize)
      s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
      subject.import_rates(:yaml, s, :without_mutex => true)
    end
  end

  describe "#rate_key_for" do
    it "accepts str/str" do
      expect { subject.send(:rate_key_for, 'USD', 'EUR')}.to_not raise_exception
    end

    it "accepts currency/str" do
      expect { subject.send(:rate_key_for, Money::Currency.wrap('USD'), 'EUR')}.to_not raise_exception
    end

    it "accepts str/currency" do
      expect { subject.send(:rate_key_for, 'USD', Money::Currency.wrap('EUR'))}.to_not raise_exception
    end

    it "accepts currency/currency" do
      expect { subject.send(:rate_key_for, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))}.to_not raise_exception
    end

    it "returns a hashkey based on the passed arguments" do
      expect(subject.send(:rate_key_for, 'USD', 'EUR')).to eq 'USD_TO_EUR'
      expect(subject.send(:rate_key_for, Money::Currency.wrap('USD'), 'EUR')).to eq 'USD_TO_EUR'
      expect(subject.send(:rate_key_for, 'USD', Money::Currency.wrap('EUR'))).to eq 'USD_TO_EUR'
      expect(subject.send(:rate_key_for, Money::Currency.wrap('USD'), Money::Currency.wrap('EUR'))).to eq 'USD_TO_EUR'
    end

    it "raises a Money::Currency::UnknownCurrency exception when an unknown currency is passed" do
      expect { subject.send(:rate_key_for, 'AAA', 'BBB')}.to raise_exception(Money::Currency::UnknownCurrency)
    end
  end

  describe "#marshal_dump" do
    it "does not raise an error" do
      expect {  Marshal.dump(subject) }.to_not raise_error
    end

    it "works with Marshal.load" do
      bank = Marshal.load(Marshal.dump(subject))

      expect(bank.rates).to           eq subject.rates
      expect(bank.rounding_method).to eq subject.rounding_method
    end
  end
end
