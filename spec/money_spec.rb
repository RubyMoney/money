# frozen_string_literal: true

Subclass = Class.new(Money)

RSpec.describe Money do
  describe ".locale_backend" do
    after { Money.locale_backend = :currency }

    it "sets the locale_backend" do
      Money.locale_backend = :i18n

      expect(Money.locale_backend).to be_a(Money::LocaleBackend::I18n)
    end

    it "sets the locale_backend to nil" do
      Money.locale_backend = nil

      expect(Money.locale_backend).to be_nil
    end
  end

  describe ".new" do
    subject(:money) { Money.new(initializing_value) }

    let(:initializing_value) { 1 }

    it "is an instance of `Money::Bank::VariableExchange`" do
      expect(money.bank).to be Money::Bank::VariableExchange.instance
    end

    context "when the initializing value is an integer" do
      let(:initializing_value) { Integer(1) }

      it "stores the integer as the number of cents" do
        expect(money.cents).to eq initializing_value
      end
    end

    context "when the initializing value is a float" do
      context "when the value is 1.00" do
        let(:initializing_value) { 1.00 }

        it { is_expected.to eq Money.new(1) }
      end

      context "when the value is 1.01" do
        let(:initializing_value) { 1.01 }

        it { is_expected.to eq Money.new(1) }
      end

      context "when the value is 1.50" do
        let(:initializing_value) { 1.50 }

        it { is_expected.to eq Money.new(2) }
      end
    end

    context "when the initializing value is a rational" do
      let(:initializing_value) { Rational(1) }

      it { is_expected.to eq Money.new(1) }
    end

    context "when the initializing value is money" do
      let(:initializing_value) { Money.new(1_00, Money::Currency.new("NZD")) }

      it { is_expected.to eq initializing_value }
    end

    context "when the initializing value doesn't respond to .to_d" do
      let(:initializing_value) { :"1" }

      it { is_expected.to eq Money.new(1) }
    end

    context "when a currency is not provided" do
      subject(:money) { Money.new(initializing_value) }

      it "has the default currency" do
        expect(money.currency).to eq Money.default_currency
      end

      context "without a default" do
        it "throws an NoCurrency Error" do
          Money.default_currency = nil

          expect { money }.to raise_error(Money::Currency::NoCurrency)
        end
      end
    end

    context "when a currency is provided" do
      subject(:money) { Money.new(initializing_value, currency) }

      context "when the currency is NZD" do
        let(:currency) { Money::Currency.new("NZD") }

        it "has NZD currency" do
          expect(money.currency).to eq Money::Currency.new("NZD")
        end
      end

      context "when the currency is nil" do
        let(:currency) { nil }

        it "has the default currency" do
          expect(money.currency).to eq Money.default_currency
        end
      end
    end

    context "when a non-finite value is given" do
      let(:error) { "must be initialized with a finite value" }

      it "raises an error when trying to initialize with Infinity" do
        expect { Money.new("Infinity") }.to raise_error(ArgumentError, error)
        expect { Money.new(BigDecimal("Infinity")) }.to raise_error(ArgumentError, error)
      end

      it "raises an error when trying to initialize with NaN" do
        expect { Money.new("NaN") }.to raise_error(ArgumentError, error)
        expect { Money.new(BigDecimal("NaN")) }.to raise_error(ArgumentError, error)
      end
    end

    context "with infinite_precision", :default_infinite_precision_true do
      context "when the initializing value is 1.50" do
        let(:initializing_value) { 1.50 }

        it "has the correct cents" do
          expect(money.cents).to eq BigDecimal("1.50")
        end
      end
    end

    context "when initializing with .from_cents" do
      subject(:money) { Money.from_cents(initializing_value) }

      it "works just as with .new" do
        expect(money.cents).to eq initializing_value
      end
    end

    context "when initializing with .from_dollars" do
      subject(:money) { Money.from_dollars(initializing_value) }

      it "is a deprecated synonym of .from_amount" do
        allow(Money).to receive(:warn)
        expect(money.amount).to eq initializing_value
        expect(Money).to have_received(:warn).with(/DEPRECATION/)
      end
    end
  end

  describe ".add_rate" do
    around do |example|
      previous_bank = Money.default_bank
      Money.default_bank = Money::Bank::VariableExchange.new

      example.call

      Money.default_bank = previous_bank
    end

    it "saves rate into current bank" do
      Money.add_rate("EUR", "USD", 10)
      expect(Money.new(10_00, "EUR").exchange_to("USD")).to eq Money.new(100_00, "USD")
    end
  end

  describe ".disallow_currency_conversions!" do
    around do |example|
      default_bank = Money.default_bank
      example.call
      Money.default_bank = default_bank
    end

    it "disallows conversions when doing money arithmetic" do
      Money.disallow_currency_conversion!
      expect { Money.new(100, "USD") + Money.new(100, "EUR") }.to raise_error(Money::Bank::DifferentCurrencyError)
    end
  end

  describe ".from_amount" do
    it "accepts numeric values" do
      expect(Money.from_amount(1, "USD")).to eq Money.new(1_00, "USD")
      expect(Money.from_amount(1.0, "USD")).to eq Money.new(1_00, "USD")
      expect(Money.from_amount("1".to_d, "USD")).to eq Money.new(1_00, "USD")
    end

    it "raises ArgumentError with unsupported argument" do
      expect { Money.from_amount("1") }.to raise_error(ArgumentError)
      expect { Money.from_amount(Object.new) }.to raise_error(ArgumentError)
    end

    it "converts given amount to subunits according to currency" do
      expect(Money.from_amount(1, "USD")).to eq Money.new(1_00, "USD")
      expect(Money.from_amount(1, "TND")).to eq Money.new(1_000, "TND")
      expect(Money.from_amount(1, "JPY")).to eq Money.new(1, "JPY")
    end

    it "rounds the given amount to subunits" do
      expect(Money.from_amount(4.444, "USD").amount).to eq "4.44".to_d
      expect(Money.from_amount(5.555, "USD").amount).to eq "5.56".to_d
      expect(Money.from_amount(444.4, "JPY").amount).to eq "444".to_d
      expect(Money.from_amount(555.5, "JPY").amount).to eq "556".to_d
    end

    it "does not round the given amount when infinite_precision is set", :default_infinite_precision_true do
      expect(Money.from_amount(4.444, "USD").amount).to eq "4.444".to_d
      expect(Money.from_amount(5.555, "USD").amount).to eq "5.555".to_d
      expect(Money.from_amount(444.4, "JPY").amount).to eq "444.4".to_d
      expect(Money.from_amount(555.5, "JPY").amount).to eq "555.5".to_d
    end

    it "accepts an optional currency" do
      expect(Money.from_amount(1).currency).to eq Money.default_currency
      jpy = Money::Currency.wrap("JPY")
      expect(Money.from_amount(1, jpy).currency).to eq jpy
      expect(Money.from_amount(1, "JPY").currency).to eq jpy
    end

    it "accepts an optional bank" do
      expect(Money.from_amount(1).bank).to eq Money.default_bank
      bank = Money::Bank::VariableExchange.new
      expect(Money.from_amount(1, "USD", bank).bank).to be bank
    end

    context "when given a nil currency" do
      let(:currency) { nil }

      it "has the default currency" do
        expect(Money.from_amount(1, currency).currency).to eq Money.default_currency
      end
    end
  end

  describe ".with_rounding_mode" do
    it "rounds using with_rounding_mode" do
      expect(Money.from_amount(1.999).to_d).to eq 2
      expect(Money.with_rounding_mode(BigDecimal::ROUND_DOWN) do
        Money.from_amount(1.999).to_d
      end).to eq 1.99
    end

    it "allows blocks nesting" do
      Money.with_rounding_mode(BigDecimal::ROUND_DOWN) do
        expect(Money.rounding_mode).to eq(BigDecimal::ROUND_DOWN)

        Money.with_rounding_mode(BigDecimal::ROUND_UP) do
          expect(Money.rounding_mode).to eq(BigDecimal::ROUND_UP)
          expect(Money.from_amount(2.137).to_d).to eq 2.14
        end

        expect(Money.rounding_mode)
          .to eq(BigDecimal::ROUND_DOWN),
              "Outer mode should be restored after inner block"
        expect(Money.from_amount(2.137).to_d).to eq 2.13
      end

      expect(Money.rounding_mode)
        .to eq(BigDecimal::ROUND_HALF_UP),
            "Original mode should be restored after outer block"
      expect(Money.from_amount(2.137).to_d).to eq 2.14
    end

    it "safely handles concurrent usage in different threads" do
      test_value = 1.999
      expected_down = 1.99
      expected_up = 2.00

      results = Queue.new

      test_money_with_rounding_mode = lambda do |rounding_mode|
        Thread.new do
          Money.with_rounding_mode(rounding_mode) do
            results.push({
              set_rounding_mode: rounding_mode,
              mode: Money.rounding_mode,
              result: Money.from_amount(test_value).to_d,
            })

            # Sleep to allow interleaving with other thread
            sleep 0.01

            results.push({
              set_rounding_mode: rounding_mode,
              mode: Money.rounding_mode,
              result: Money.from_amount(test_value).to_d,
            })
          end
        end
      end

      [
        test_money_with_rounding_mode.call(BigDecimal::ROUND_DOWN),
        test_money_with_rounding_mode.call(BigDecimal::ROUND_UP),
      ].each(&:join)

      all_results = []
      all_results << results.pop until results.empty?

      round_down_results = all_results.select { |r| r[:set_rounding_mode] == BigDecimal::ROUND_DOWN }
      round_up_results = all_results.select { |r| r[:set_rounding_mode] == BigDecimal::ROUND_UP }

      round_down_results.each do |result|
        expect(result[:mode]).to eq(BigDecimal::ROUND_DOWN)
        expect(result[:result]).to eq(expected_down)
      end

      round_up_results.each do |result|
        expect(result[:mode]).to eq(BigDecimal::ROUND_UP)
        expect(result[:result]).to eq(expected_up)
      end

      expect(Money.rounding_mode).to eq(BigDecimal::ROUND_HALF_UP)
    end
  end

  describe ".with_bank" do
    it "fallbacks to old bank after block" do
      old_bank = Money.default_bank

      bank = Money::Bank::VariableExchange.new

      Money.with_bank(bank) do
        # Do something...
      end

      expect(Money.default_bank).to eq(old_bank)
    end

    it "uses the correct bank inside block" do
      old_bank = Money.default_bank
      custom_store = double :store

      allow(old_bank).to receive(:add_rate)
      allow(custom_store).to receive(:add_rate)

      bank = Money::Bank::VariableExchange.new(custom_store)
      Money.with_bank(bank) do
        Money.add_rate("USD", "EUR", 0.5)
      end

      Money.add_rate("UAH", "NOK", 0.8)

      expect(custom_store).to have_received(:add_rate).with("USD", "EUR", 0.5)
      expect(old_bank).to have_received(:add_rate).with("UAH", "NOK", 0.8)
    end

    it "safely handles concurrent usage in different threads" do
      results = []
      results_mutex = Mutex.new
      threads = []

      custom_store = double
      custom_bank = Money::Bank::VariableExchange.new(custom_store)

      2.times do
        threads << Thread.new do
          bank_to_use = custom_bank
          expected_bank = custom_bank

          Money.with_bank(bank_to_use) do
            sleep(0.01)

            actual_bank = Money.default_bank
            result = {
              thread_id: Thread.current.object_id,
              expected: expected_bank,
              actual: actual_bank,
              match: expected_bank == actual_bank,
            }
            results_mutex.synchronize do
              results << result
            end
          end
        end
      end

      threads.each(&:join)
      mismatches = results.reject { |r| r[:match] }
      expect(mismatches.length).to be_zero
    end
  end

  describe "#cents" do
    it "is a synonym of #fractional" do
      expect(Money.new(1_23).cents).to eq(1_23)
    end
  end

  describe "#fractional" do
    it "returns the amount in fractional unit" do
      expect(Money.new(1_00).fractional).to eq 1_00
    end

    it "stores fractional as an integer regardless of what is passed into the constructor" do
      m = Money.new(100)
      expect(m.fractional).to eq 100
      expect(m.fractional).to be_a(Integer)
    end

    context "when loading a serialized Money via YAML" do
      let(:serialized) do
        <<~YAML
          !ruby/object:Money
            fractional: 249.5
            currency: !ruby/object:Money::Currency
              id: :eur
              priority: 2
              iso_code: EUR
              name: Euro
              symbol: €
              alternate_symbols: []
              subunit: Cent
              subunit_to_unit: 100
              symbol_first: true
              html_entity: ! '&#x20AC;'
              decimal_mark: ! ','
              thousands_separator: .
              iso_numeric: '978'
              mutex: !ruby/object:Thread::Mutex {}
              last_updated: 2012-11-23 20:41:47.454438399 +02:00
        YAML
      end

      let(:m) do
        if Psych::VERSION > "4.0"
          YAML.safe_load(serialized, permitted_classes: [Money, Money::Currency, Symbol, Thread::Mutex, Time])
        else
          YAML.safe_load(serialized, [Money, Money::Currency, Symbol, Thread::Mutex, Time])
        end
      end

      it "uses BigDecimal when rounding" do
        expect(m).to be_a(Money)
        expect(m.class.default_infinite_precision).to be false
        expect(m.fractional).to eq 250 # 249.5 rounded up
        expect(m.fractional).to be_a(Integer)
      end

      it "is a BigDecimal when using infinite_precision", :default_infinite_precision_true do
        expect(m.fractional).to be_a BigDecimal
      end
    end

    context "when user changes rounding_mode" do
      after { Money.setup_defaults }

      context "with the setter" do
        it "respects the rounding_mode" do
          Money.rounding_mode = BigDecimal::ROUND_DOWN
          expect(Money.new(1.9).fractional).to eq 1

          Money.rounding_mode = BigDecimal::ROUND_UP
          expect(Money.new(1.1).fractional).to eq 2
        end
      end

      context "with a block" do
        it "respects the rounding_mode" do
          expect(Money.with_rounding_mode(BigDecimal::ROUND_DOWN) do
            Money.new(1.9).fractional
          end).to eq 1

          expect(Money.with_rounding_mode(BigDecimal::ROUND_UP) do
            Money.new(1.1).fractional
          end).to eq 2

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_UP
        end

        it "works for multiplication within a block" do
          Money.with_rounding_mode(BigDecimal::ROUND_DOWN) do
            expect((Money.new(1_00) * "0.019".to_d).fractional).to eq 1
          end

          Money.with_rounding_mode(BigDecimal::ROUND_UP) do
            expect((Money.new(1_00) * "0.011".to_d).fractional).to eq 2
          end

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_UP
        end
      end
    end

    context "with infinite_precision", :default_infinite_precision_true do
      it "returns the amount in fractional unit" do
        expect(Money.new(1_00).fractional).to eq BigDecimal("100")
      end

      it "stores in fractional unit as an integer regardless of what is passed into the constructor" do
        m = Money.new(100)
        expect(m.fractional).to eq BigDecimal("100")
        expect(m.fractional).to be_a(BigDecimal)
      end
    end
  end

  describe "#round_to_nearest_cash_value" do
    it "rounds to the nearest possible cash value" do
      money = Money.new(2350, "AED")
      expect(money.round_to_nearest_cash_value).to eq 2350

      money = Money.new(-2350, "AED")
      expect(money.round_to_nearest_cash_value).to eq(-2350)

      money = Money.new(2213, "AED")
      expect(money.round_to_nearest_cash_value).to eq 2225

      money = Money.new(-2213, "AED")
      expect(money.round_to_nearest_cash_value).to eq(-2225)

      money = Money.new(2212, "AED")
      expect(money.round_to_nearest_cash_value).to eq 2200

      money = Money.new(-2212, "AED")
      expect(money.round_to_nearest_cash_value).to eq(-2200)

      money = Money.new(178, "CHF")
      expect(money.round_to_nearest_cash_value).to eq 180

      money = Money.new(-178, "CHF")
      expect(money.round_to_nearest_cash_value).to eq(-180)

      money = Money.new(177, "CHF")
      expect(money.round_to_nearest_cash_value).to eq 175

      money = Money.new(-177, "CHF")
      expect(money.round_to_nearest_cash_value).to eq(-175)

      money = Money.new(175, "CHF")
      expect(money.round_to_nearest_cash_value).to eq 175

      money = Money.new(-175, "CHF")
      expect(money.round_to_nearest_cash_value).to eq(-175)

      money = Money.new(299, "USD")
      expect(money.round_to_nearest_cash_value).to eq 299

      money = Money.new(-299, "USD")
      expect(money.round_to_nearest_cash_value).to eq(-299)

      money = Money.new(300, "USD")
      expect(money.round_to_nearest_cash_value).to eq 300

      money = Money.new(-300, "USD")
      expect(money.round_to_nearest_cash_value).to eq(-300)

      money = Money.new(301, "USD")
      expect(money.round_to_nearest_cash_value).to eq 301

      money = Money.new(-301, "USD")
      expect(money.round_to_nearest_cash_value).to eq(-301)
    end

    it "raises an error if smallest denomination is not defined" do
      money = Money.new(100, "XAG")
      expect { money.round_to_nearest_cash_value }.to raise_error(Money::UndefinedSmallestDenomination)
    end

    it "returns a Integer when infinite_precision is not set" do
      money = Money.new(100, "USD")
      expect(money.round_to_nearest_cash_value).to be_a Integer
    end

    it "returns a BigDecimal when infinite_precision is set", :default_infinite_precision_true do
      money = Money.new(100, "EUR")
      expect(money.round_to_nearest_cash_value).to be_a BigDecimal
    end
  end

  describe "#to_nearest_cash_value" do
    it "rounds to the nearest possible cash value" do
      expect(Money.new(23_50, "AED").to_nearest_cash_value).to eq(Money.new(23_50, "AED"))
      expect(Money.new(-23_50, "AED").to_nearest_cash_value).to eq(Money.new(-23_50, "AED"))
      expect(Money.new(22_13, "AED").to_nearest_cash_value).to eq(Money.new(22_25, "AED"))
      expect(Money.new(-22_13, "AED").to_nearest_cash_value).to eq(Money.new(-22_25, "AED"))
      expect(Money.new(22_12, "AED").to_nearest_cash_value).to eq(Money.new(22_00, "AED"))
      expect(Money.new(-22_12, "AED").to_nearest_cash_value).to eq(Money.new(-22_00, "AED"))

      expect(Money.new(1_78, "CHF").to_nearest_cash_value).to eq(Money.new(1_80, "CHF"))
      expect(Money.new(-1_78, "CHF").to_nearest_cash_value).to eq(Money.new(-1_80, "CHF"))
      expect(Money.new(1_77, "CHF").to_nearest_cash_value).to eq(Money.new(1_75, "CHF"))
      expect(Money.new(-1_77, "CHF").to_nearest_cash_value).to eq(Money.new(-1_75, "CHF"))
      expect(Money.new(1_75, "CHF").to_nearest_cash_value).to eq(Money.new(1_75, "CHF"))
      expect(Money.new(-1_75, "CHF").to_nearest_cash_value).to eq(Money.new(-1_75, "CHF"))

      expect(Money.new(2_99, "USD").to_nearest_cash_value).to eq(Money.new(2_99, "USD"))
      expect(Money.new(-2_99, "USD").to_nearest_cash_value).to eq(Money.new(-2_99, "USD"))
      expect(Money.new(3_00, "USD").to_nearest_cash_value).to eq(Money.new(3_00, "USD"))
      expect(Money.new(-3_00, "USD").to_nearest_cash_value).to eq(Money.new(-3_00, "USD"))
      expect(Money.new(3_01, "USD").to_nearest_cash_value).to eq(Money.new(3_01, "USD"))
      expect(Money.new(-3_01, "USD").to_nearest_cash_value).to eq(Money.new(-3_01, "USD"))
    end

    it "raises an error if smallest denomination is not defined" do
      expect { Money.new(1_00, "XAG").to_nearest_cash_value }
        .to raise_error(Money::UndefinedSmallestDenomination)
    end
  end

  describe "#amount" do
    it "returns the amount of cents as the full unit" do
      expect(Money.new(1_00).amount).to eq 1
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(1_00,  "USD").amount).to eq 1
      expect(Money.new(1_000, "TND").amount).to eq 1
      expect(Money.new(1,     "VUV").amount).to eq 1
      expect(Money.new(1,     "CLP").amount).to eq 1
    end

    it "does not lose precision" do
      expect(Money.new(100_37).amount).to eq 100.37
    end

    it "produces a BigDecimal" do
      expect(Money.new(1_00).amount).to be_a BigDecimal
    end
  end

  describe "#dollars" do
    it "is a deprecated synonym of #amount" do
      money = Money.new(1_23)

      allow(money).to receive(:warn)
      expect(money.dollars).to eq(1.23)
      expect(money).to have_received(:warn).with(/DEPRECATION/)
    end
  end

  describe "#currency" do
    it "returns the currency object" do
      expect(Money.new(1_00, "USD").currency).to eq Money::Currency.new("USD")
    end
  end

  describe "#hash=" do
    it "returns the same value for equal objects" do
      expect(Money.new(1_00, "EUR").hash).to eq Money.new(1_00, "EUR").hash
      expect(Money.new(2_00, "USD").hash).to eq Money.new(2_00, "USD").hash
      expect(Money.new(1_00, "EUR").hash).not_to eq Money.new(2_00, "EUR").hash
      expect(Money.new(1_00, "EUR").hash).not_to eq Money.new(1_00, "USD").hash
      expect(Money.new(1_00, "EUR").hash).not_to eq Money.new(2_00, "USD").hash
    end

    it "can be used to return the intersection of Money object arrays" do
      intersection = [Money.new(1_00, "EUR"), Money.new(1_00, "USD")] & [Money.new(1_00, "EUR")]
      expect(intersection).to eq [Money.new(1_00, "EUR")]
    end
  end

  describe "#symbol" do
    it "returns the currency’s symbol" do
      expect(Money.new(0, "EUR").symbol).to eq("€")
    end

    context "when the currency has no symbol" do
      let(:currency) { Money::Currency.new("EUR") }

      before do
        allow(currency).to receive(:symbol).and_return(nil)
      end

      it "returns a generic currency symbol" do
        expect(Money.new(0, currency).symbol).to eq "¤"
      end
    end
  end

  describe "#to_s" do
    it "works as documented" do
      expect(Money.new(10_00).to_s).to eq "10.00"
      expect(Money.new(400_08).to_s).to eq "400.08"
      expect(Money.new(-237_43).to_s).to eq "-237.43"
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(10_00, "BHD").to_s).to eq "1.000"
      expect(Money.new(10_00, "CNY").to_s).to eq "10.00"
    end

    it "does not have decimal when :subunit_to_unit == 1" do
      expect(Money.new(10_00, "VUV").to_s).to eq "1000"
    end

    it "does not work when :subunit_to_unit == 5" do
      expect(Money.new(10_00, "MRU").to_s).to eq "200.0"
    end

    it "respects :decimal_mark" do
      expect(Money.new(10_00, "BRL").to_s).to eq "10,00"
    end

    context "when using i18n", :locale_backend_i18n do
      before do
        I18n.backend.store_translations(:en, number: { format: { separator: "." } })
      end

      it "respects decimal mark" do
        expect(Money.new(10_00, "BRL").to_s).to eq "10.00"
      end
    end

    context "with defaults set" do
      before { Money.default_formatting_rules = { with_currency: true } }
      after { Money.default_formatting_rules = nil }

      it "ignores defaults" do
        expect(Money.new(10_00, "USD").to_s).to eq "10.00"
      end
    end

    context "with infinite_precision", :default_infinite_precision_true do
      it "shows fractional cents" do
        expect(Money.new(1.05, "USD").to_s).to eq "0.0105"
      end

      it "suppresses fractional cents when there is none" do
        expect(Money.new(1.0, "USD").to_s).to eq "0.01"
      end

      it "shows fractional if needed when :subunut_to_unit == 1" do
        expect(Money.new(10_00.1, "VUV").to_s).to eq "1000.1"
      end
    end
  end

  describe "#to_d" do
    it "works as documented" do
      decimal = Money.new(10_00).to_d
      expect(decimal).to be_a(BigDecimal)
      expect(decimal).to eq 10.0
    end

    it "respects :subunit_to_unit currency property" do
      decimal = Money.new(10_00, "BHD").to_d
      expect(decimal).to be_a(BigDecimal)
      expect(decimal).to eq 1.0
    end

    it "works with float :subunit_to_unit currency property" do
      money = Money.new(10_00, "BHD")
      allow(money.currency).to receive(:subunit_to_unit).and_return(1000.0)

      decimal = money.to_d
      expect(decimal).to be_a(BigDecimal)
      expect(decimal).to eq 1.0
    end
  end

  describe "#to_f" do
    it "works as documented" do
      expect(Money.new(10_00).to_f).to eq 10.0
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(10_00, "BHD").to_f).to eq 1.0
    end
  end

  describe "#to_i" do
    it "works as documented" do
      expect(Money.new(10_00).to_i).to eq 10
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(10_00, "BHD").to_i).to eq 1
    end
  end

  describe "#to_money" do
    it "works as documented" do
      money = Money.new(10_00, "DKK")
      allow(money.bank)
        .to receive(:exchange_with)
        .and_return(Money.new(200_00, Money::Currency.new("EUR")))
      expect(money).to eq money.to_money
      expect(money).to eq money.to_money("DKK")
      expect(money.to_money("EUR")).to eq Money.new(200_00, "EUR")
      expect(money.bank)
        .to have_received(:exchange_with)
        .with(Money.new(10_00, Money::Currency.new("DKK")), Money::Currency.new("EUR"))
    end
  end

  describe "#with_currency" do
    it "returns self if currency is the same" do
      money = Money.new(10_00, "USD")

      expect(money.with_currency("USD")).to eq(money)
      expect(money.with_currency("USD").object_id).to eq(money.object_id)
    end

    it "returns a new instance in a given currency" do
      money = Money.new(10_00, "USD")
      new_money = money.with_currency("EUR")

      expect(new_money).to eq(Money.new(10_00, "EUR"))
      expect(money.fractional).to eq(new_money.fractional)
      expect(money.bank).to eq(new_money.bank)
      expect(money.object_id).not_to eq(new_money.object_id)
    end
  end

  describe "#exchange_to" do
    it "exchanges the amount via its exchange bank" do
      money = Money.new(100_00, "USD")
      allow(money.bank)
        .to receive(:exchange_with)
        .and_return(Money.new(200_00, Money::Currency.new("EUR")))
      money.exchange_to("EUR")
      expect(money.bank)
        .to have_received(:exchange_with)
        .with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR"))
    end

    it "exchanges the amount properly" do
      money = Money.new(100_00, "USD")
      allow(money.bank)
        .to receive(:exchange_with)
        .and_return(Money.new(200_00, Money::Currency.new("EUR")))
      expect(money.exchange_to("EUR")).to eq Money.new(200_00, "EUR")
      expect(money.bank)
        .to have_received(:exchange_with)
        .with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR"))
    end

    it "allows double conversion using same bank" do
      bank = Money::Bank::VariableExchange.new
      bank.add_rate("EUR", "USD", 2)
      bank.add_rate("USD", "EUR", 0.5)
      money = Money.new(100_00, "USD", bank)
      expect(money.exchange_to("EUR").exchange_to("USD")).to eq money
    end

    it "uses the block given as rounding method" do
      money = Money.new(100_00, "USD")
      allow(money.bank).to receive(:exchange_with).and_yield(300_00)
      expect { |block| money.exchange_to(Money::Currency.new("EUR"), &block) }
        .to yield_successive_args(300_00)
      expect(money.bank).to have_received(:exchange_with)
    end

    it "does no exchange when the currencies are the same" do
      money = Money.new(100_00, "USD")
      allow(money.bank).to receive(:exchange_with)
      expect(money.exchange_to("USD")).to eq money
      expect(money.bank).not_to have_received(:exchange_with)
    end
  end

  describe "#allocate" do
    it "takes no action when one gets all" do
      expect(Money.us_dollar(5).allocate([1.0])).to eq [Money.us_dollar(5)]
    end

    it "keeps currencies intact" do
      expect(Money.ca_dollar(5).allocate([1])).to eq [Money.ca_dollar(5)]
    end

    it "handles small splits" do
      moneys = Money.us_dollar(5).allocate([0.03, 0.07])
      expect(moneys[0]).to eq Money.us_dollar(2)
      expect(moneys[1]).to eq Money.us_dollar(3)
    end

    it "handles large splits" do
      moneys = Money.us_dollar(5).allocate([3, 7])
      expect(moneys[0]).to eq Money.us_dollar(2)
      expect(moneys[1]).to eq Money.us_dollar(3)
    end

    it "does not lose pennies for one decimal" do
      moneys = Money.us_dollar(5).allocate([0.3, 0.7])
      expect(moneys[0]).to eq Money.us_dollar(2)
      expect(moneys[1]).to eq Money.us_dollar(3)
    end

    it "does not lose pennies for three decimals" do
      moneys = Money.us_dollar(1_00).allocate([0.333, 0.333, 0.333])
      expect(moneys[0].cents).to eq 34
      expect(moneys[1].cents).to eq 33
      expect(moneys[2].cents).to eq 33
    end

    it "does not round rationals" do
      splits = Array.new(7) { Rational(950, 6650) }
      moneys = Money.us_dollar(6650).allocate(splits)
      moneys.each do |money|
        expect(money.cents).to eq 950
      end
    end

    it "handles mixed split types" do
      splits = [Rational(1, 4), 0.25, 0.25, BigDecimal("0.25")]
      moneys = Money.us_dollar(100).allocate(splits)
      moneys.each do |money|
        expect(money.cents).to eq 25
      end
    end

    context "when amount is negative" do
      it "does not lose pennies" do
        moneys = Money.us_dollar(-100).allocate([0.333, 0.333, 0.333])

        expect(moneys[0].cents).to eq(-34)
        expect(moneys[1].cents).to eq(-33)
        expect(moneys[2].cents).to eq(-33)
      end

      it "allocates the same way as positive amounts" do
        ratios = [0.6667, 0.3333]

        expect(Money.us_dollar(10_00).allocate(ratios).map(&:fractional)).to eq([6_67, 3_33])
        expect(Money.us_dollar(-10_00).allocate(ratios).map(&:fractional)).to eq([-6_67, -3_33])
      end
    end

    context "with all zeros" do
      let(:moneys) { Money.us_dollar(100).allocate([0, 0]) }

      it "allocates evenly" do
        expect(moneys.map(&:fractional)).to eq [50, 50]
      end
    end

    it "keeps subclasses intact" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(5).allocate([1]).first).to be_a special_money_class
    end

    context "with infinite_precision", :default_infinite_precision_true do
      it "allows for fractional cents allocation" do
        moneys = Money.new(100).allocate([1, 1, 1])
        expect(moneys.sum).to eq(Money.new(100))
      end
    end
  end

  describe "#split" do
    it "needs at least one party" do
      expect { Money.us_dollar(1).split(0) }.to raise_error(ArgumentError)
      expect { Money.us_dollar(1).split(-1) }.to raise_error(ArgumentError)
    end

    it "gives 1 cent to both people if we start with 2" do
      expect(Money.us_dollar(2).split(2)).to eq [Money.us_dollar(1), Money.us_dollar(1)]
    end

    it "may distribute no money to some parties if there isnt enough to go around" do
      expect(Money.us_dollar(2).split(3)).to eq [Money.us_dollar(1), Money.us_dollar(1), Money.us_dollar(0)]
    end

    it "does not lose pennies" do
      expect(Money.us_dollar(5).split(2)).to eq [Money.us_dollar(3), Money.us_dollar(2)]
    end

    it "splits a dollar" do
      moneys = Money.us_dollar(100).split(3)
      expect(moneys[0].cents).to eq 34
      expect(moneys[1].cents).to eq 33
      expect(moneys[2].cents).to eq 33
    end

    it "preserves the class in the result when using a subclass of Money" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(10_00).split(1).first).to be_a special_money_class
    end

    context "with infinite_precision", :default_infinite_precision_true do
      it "allows for splitting by fractional cents" do
        moneys = Money.new(100).split(3)
        expect(moneys.sum).to eq(Money.new(100))
      end
    end
  end

  describe "#round" do
    subject(:rounded) { money.round }

    let(:money) { Money.new(15.75, "NZD") }

    context "without infinite_precision" do
      it "returns a different money" do
        expect(rounded).not_to be money
      end

      it "rounds the cents" do
        expect(rounded.cents).to eq 16
      end

      it "maintains the currency" do
        expect(rounded.currency).to eq Money::Currency.new("NZD")
      end

      it "uses a provided rounding strategy" do
        rounded = money.round(BigDecimal::ROUND_DOWN)
        expect(rounded.cents).to eq 15
      end

      it "does not accumulate rounding error" do
        money1 = Money.new(10.9).round(BigDecimal::ROUND_DOWN)
        money2 = Money.new(10.9).round(BigDecimal::ROUND_DOWN)

        expect(money1 + money2).to eq(Money.new(20))
      end
    end

    context "with infinite_precision", :default_infinite_precision_true do
      it "returns a different money" do
        expect(rounded).not_to be money
      end

      it "rounds the cents" do
        expect(rounded.cents).to eq 16
      end

      it "maintains the currency" do
        expect(rounded.currency).to eq Money::Currency.new("NZD")
      end

      it "uses a provided rounding strategy" do
        rounded = money.round(BigDecimal::ROUND_DOWN)
        expect(rounded.cents).to eq 15
      end

      context "when using a specific rounding precision" do
        let(:money) { Money.new(15.7526, "NZD") }

        it "uses the provided rounding precision" do
          rounded = money.round(BigDecimal::ROUND_DOWN, 3)
          expect(rounded.fractional).to eq 15.752
        end
      end
    end

    it "preserves assigned bank" do
      bank = Money::Bank::VariableExchange.new
      rounded = Money.new(1_00, "USD", bank).round

      expect(rounded.bank).to eq(bank)
    end

    context "when using a subclass of Money" do
      let(:special_money_class) { Class.new(Money) }
      let(:money) { special_money_class.new(15.75, "NZD") }

      it "preserves the class in the result" do
        expect(rounded).to be_a special_money_class
      end
    end
  end

  describe "#inspect" do
    it "reports the class name properly when using inheritance" do
      expect(Money.new(1).inspect).to start_with "#<Money"
      expect(Subclass.new(1).inspect).to start_with "#<Subclass"
    end
  end

  describe "#as_*" do
    before do
      Money.default_bank = Money::Bank::VariableExchange.new
      Money.add_rate("EUR", "USD", 1)
      Money.add_rate("EUR", "CAD", 1)
      Money.add_rate("USD", "EUR", 1)
    end

    after do
      Money.default_bank = Money::Bank::VariableExchange.instance
    end

    specify "as_us_dollar converts Money object to USD" do
      obj = Money.new(1, "EUR")
      expect(obj.as_us_dollar).to eq Money.new(1, "USD")
    end

    specify "as_ca_dollar converts Money object to CAD" do
      obj = Money.new(1, "EUR")
      expect(obj.as_ca_dollar).to eq Money.new(1, "CAD")
    end

    specify "as_euro converts Money object to EUR" do
      obj = Money.new(1, "USD")
      expect(obj.as_euro).to eq Money.new(1, "EUR")
    end
  end

  describe ".default_currency" do
    before do
      allow(Money).to receive(:warn)

      Money.setup_defaults
    end

    after do
      Money.setup_defaults
    end

    it "accepts a lambda" do
      Money.default_currency = -> { :eur }
      expect(Money.default_currency).to eq Money::Currency.new(:eur)
    end

    it "accepts a symbol" do
      Money.default_currency = :eur
      expect(Money.default_currency).to eq Money::Currency.new(:eur)
    end

    it "does not warn if the default_currency has been changed" do
      Money.default_currency = Money::Currency.new(:usd)

      Money.default_currency

      expect(Money).not_to have_received(:warn)
    end
  end

  describe ".default_bank" do
    after { Money.setup_defaults }

    it "accepts a bank instance" do
      Money.default_bank = Money::Bank::SingleCurrency.instance
      expect(Money.default_bank).to be_instance_of(Money::Bank::SingleCurrency)
    end

    it "accepts a lambda" do
      Money.default_bank = -> { Money::Bank::SingleCurrency.instance }
      expect(Money.default_bank).to be_instance_of(Money::Bank::SingleCurrency)
    end
  end

  describe "VERSION" do
    it "exposes a version with major, minor and patch level" do
      expect(Money::VERSION).to match(/\d+.\d+.\d+/)
    end
  end
end
