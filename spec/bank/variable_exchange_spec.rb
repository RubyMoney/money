# frozen_string_literal: true

require "json"
require "yaml"

RSpec.describe Money::Bank::VariableExchange do
  subject(:bank) { described_class.new }

  describe "#initialize" do
    context "without &block" do
      let(:bank) do
        described_class.new.tap do |bank|
          bank.add_rate("USD", "EUR", 1.33)
        end
      end

      describe "#store" do
        it "defaults to Memory store" do
          expect(bank.store).to be_a(Money::RatesStore::Memory)
        end
      end

      describe "custom store" do
        let(:custom_store) { Object.new }

        it "sets #store to be custom store" do
          bank = described_class.new(custom_store)
          expect(bank.store).to eql(custom_store)
        end

        it "allows passing custom store as a string" do
          bank = described_class.new("Object")
          expect(bank.store).to eql(Object)
        end
      end

      describe "#exchange_with" do
        it "accepts str" do
          expect { bank.exchange_with(Money.new(100, "USD"), "EUR") }.not_to raise_error
        end

        it "accepts currency" do
          expect { bank.exchange_with(Money.new(100, "USD"), Money::Currency.wrap("EUR")) }.not_to raise_error
        end

        it "exchanges one currency to another" do
          expect(bank.exchange_with(Money.new(100, "USD"), "EUR")).to eq Money.new(133, "EUR")
        end

        it "truncates extra digits" do
          expect(bank.exchange_with(Money.new(10, "USD"), "EUR")).to eq Money.new(13, "EUR")
        end

        it "raises an UnknownCurrency error when an unknown currency is requested" do
          expect { bank.exchange_with(Money.new(100, "USD"), "BBB") }.to raise_error(Money::Currency::UnknownCurrency)
        end

        it "raises an UnknownRate error when an unknown rate is requested" do
          expect { bank.exchange_with(Money.new(100, "USD"), "JPY") }.to raise_error(Money::Bank::UnknownRate)
        end

        # it "rounds the exchanged result down" do
        #   bank.add_rate("USD", "EUR", 0.788332676)
        #   bank.add_rate("EUR", "YEN", 122.631477)
        #   expect(bank.exchange_with(Money.new(10_00,  "USD"), "EUR")).to eq Money.new(788, "EUR")
        #   expect(bank.exchange_with(Money.new(500_00, "EUR"), "YEN")).to eq Money.new(6131573, "YEN")
        # end

        it "accepts a custom truncation method" do
          proc = proc(&:ceil)
          expect(bank.exchange_with(Money.new(10, "USD"), "EUR", &proc)).to eq Money.new(14, "EUR")
        end

        it "works with big numbers" do
          amount = 10**20
          expect(bank.exchange_with(Money.usd(amount), :EUR)).to eq Money.eur(1.33 * amount)
        end

        it "preserves the class in the result when given a subclass of Money" do
          special_money_class = Class.new(Money)
          expect(bank.exchange_with(special_money_class.new(100, "USD"), "EUR")).to be_a special_money_class
        end

        it "doesn't lose precision when handling larger amounts" do
          expect(bank.exchange_with(Money.new(100_000_000_000_000_01, "USD"), "EUR")).to eq Money.new(133_000_000_000_000_01, "EUR")
        end
      end
    end

    context "with &block" do
      let(:bank) do
        proc = proc(&:ceil)
        described_class.new(&proc).tap do |bank|
          bank.add_rate("USD", "EUR", 1.33)
        end
      end

      describe "#exchange_with" do
        it "uses the stored truncation method" do
          expect(bank.exchange_with(Money.new(10, "USD"), "EUR")).to eq Money.new(14, "EUR")
        end

        it "accepts a custom truncation method" do
          proc = proc { |n| n.ceil + 1 }
          expect(bank.exchange_with(Money.new(10, "USD"), "EUR", &proc)).to eq Money.new(15, "EUR")
        end
      end
    end
  end

  describe "#add_rate" do
    it "delegates to store#add_rate" do
      allow(bank.store).to receive(:add_rate).and_return 1.25
      expect(bank.add_rate("USD", "EUR", 1.25)).to be 1.25
      expect(bank.store).to have_received(:add_rate).with("USD", "EUR", 1.25)
    end

    it "adds rates with correct ISO codes" do
      allow(bank.store).to receive(:add_rate)
      bank.add_rate("USD", "EUR", 0.788332676)
      expect(bank.store).to have_received(:add_rate).with("USD", "EUR", 0.788332676)

      bank.add_rate("EUR", "YEN", 122.631477)
      expect(bank.store).to have_received(:add_rate).with("EUR", "JPY", 122.631477)
    end

    it "treats currency names case-insensitively" do
      bank.add_rate("usd", "eur", 1)
      expect(bank.get_rate("USD", "EUR")).to eq 1
    end
  end

  describe "#set_rate" do
    it "delegates to store#add_rate" do
      allow(bank.store).to receive(:add_rate).and_return 1.25
      expect(bank.set_rate("USD", "EUR", 1.25)).to be 1.25
      expect(bank.store).to have_received(:add_rate).with("USD", "EUR", 1.25)
    end

    it "sets a rate" do
      bank.set_rate("USD", "EUR", 1.25)
      expect(bank.store.get_rate("USD", "EUR")).to eq 1.25
    end

    it "raises an UnknownCurrency error when an unknown currency is passed" do
      expect { bank.set_rate("AAA", "BBB", 1.25) }.to raise_error(Money::Currency::UnknownCurrency)
    end
  end

  describe "#get_rate" do
    it "returns a rate" do
      bank.set_rate("USD", "EUR", 1.25)
      expect(bank.get_rate("USD", "EUR")).to eq 1.25
    end

    it "raises an UnknownCurrency error when an unknown currency is passed" do
      expect { bank.get_rate("AAA", "BBB") }.to raise_error(Money::Currency::UnknownCurrency)
    end

    it "delegates options to store, options are a no-op" do
      allow(bank.store).to receive(:get_rate)
      bank.get_rate("USD", "EUR")
      expect(bank.store).to have_received(:get_rate).with("USD", "EUR")
    end
  end

  describe "#export_rates" do
    let(:expected_rates) { { "USD_TO_EUR" => 1.25, "USD_TO_JPY" => 2.55 } }

    before do
      bank.set_rate("USD", "EUR", 1.25)
      bank.set_rate("USD", "JPY", 2.55)
    end

    context "with format == :json" do
      it "returns rates formatted as json" do
        json = bank.export_rates(:json)
        expect(JSON.parse(json)).to eq expected_rates
      end
    end

    context "with format == :ruby" do
      # rubocop:disable Security/MarshalLoad
      it "returns rates formatted as ruby objects" do
        expect(Marshal.load(bank.export_rates(:ruby))).to eq expected_rates
      end
      # rubocop:enable Security/MarshalLoad
    end

    context "with format == :yaml" do
      it "returns rates formatted as yaml" do
        yaml = bank.export_rates(:yaml)
        expect(YAML.load(yaml)).to eq expected_rates
      end
    end

    context "with unknown format" do
      it "raises Money::Bank::UnknownRateFormat" do
        expect { bank.export_rates(:foo) }.to raise_error Money::Bank::UnknownRateFormat
      end
    end

    context "with :file provided" do
      it "writes rates to file" do
        allow(File).to receive(:write)

        bank.export_rates(:json, "null")

        expect(File).to have_received(:write).with("null", JSON.dump(expected_rates))
      end
    end

    it "delegates execution to store, options are a no-op" do
      allow(bank.store).to receive(:transaction)
      bank.export_rates(:yaml, nil, foo: 1)
      expect(bank.store).to have_received(:transaction)
    end
  end

  describe "#import_rates" do
    context "with format == :json" do
      it "loads the rates provided" do
        s = '{"USD_TO_EUR":1.25,"USD_TO_JPY":2.55}'
        bank.import_rates(:json, s)
        expect(bank.get_rate("USD", "EUR")).to eq 1.25
        expect(bank.get_rate("USD", "JPY")).to eq 2.55
      end
    end

    context "with format == :ruby" do
      let(:dump) { Marshal.dump({ "USD_TO_EUR" => 1.25, "USD_TO_JPY" => 2.55 }) }

      it "loads the rates provided" do
        bank.import_rates(:ruby, dump)

        expect(bank.get_rate("USD", "EUR")).to eq 1.25
        expect(bank.get_rate("USD", "JPY")).to eq 2.55
      end

      # rubocop:disable RSpec/SubjectStub
      it "prints a warning" do
        allow(bank).to receive(:warn)

        bank.import_rates(:ruby, dump)

        expect(bank)
          .to have_received(:warn)
          .with(include("[WARNING] Using :ruby format when importing rates is potentially unsafe"))
      end
      # rubocop:enable RSpec/SubjectStub
    end

    context "with format == :yaml" do
      it "loads the rates provided" do
        s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
        bank.import_rates(:yaml, s)
        expect(bank.get_rate("USD", "EUR")).to eq 1.25
        expect(bank.get_rate("USD", "JPY")).to eq 2.55
      end
    end

    context "with unknown format" do
      it "raises Money::Bank::UnknownRateFormat" do
        expect { bank.import_rates(:foo, "") }
          .to raise_error Money::Bank::UnknownRateFormat
      end
    end

    it "delegates execution to store#transaction" do
      allow(bank.store).to receive(:transaction)
      s = "--- \nUSD_TO_EUR: 1.25\nUSD_TO_JPY: 2.55\n"
      bank.import_rates(:yaml, s, foo: 1)
      expect(bank.store).to have_received(:transaction)
    end
  end

  describe "#marshal_dump" do
    it "does not raise an error" do
      expect { Marshal.dump(bank) }.not_to raise_error
    end

    it "works with Marshal.load" do
      new_bank = Marshal.load(Marshal.dump(bank))

      expect(new_bank.rates).to eq bank.rates
      expect(new_bank.rounding_method).to eq bank.rounding_method
    end
  end
end
