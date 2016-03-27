# encoding: utf-8

describe Money do
  describe ".new" do
    let(:initializing_value) { 1 }
    subject(:money) { Money.new(initializing_value) }

    it "should be an instance of `Money::Bank::VariableExchange`" do
      expect(money.bank).to be Money::Bank::VariableExchange.instance
    end

    it 'stores the integer as the number of cents' do
      expect(money.fractional).to be initializing_value
    end

    context 'given the initializing value is a float' do
      context 'and the value is 1.00' do
        let(:initializing_value) { 1.00 }
        it { is_expected.to eq Money.new(1) }
      end

      context 'and the value is 1.01' do
        let(:initializing_value) { 1.01 }
        it { is_expected.to eq Money.new(1) }
      end

      context 'and the value is 1.50' do
        let(:initializing_value) { 1.50 }
        it { is_expected.to eq Money.new(2) }
      end
    end

    context 'given the initializing value is a rational' do
      let(:initializing_value) { Rational(1) }
      it { is_expected.to eq Money.new(1) }
    end

    context 'given the initializing value is money' do
      let(:initializing_value) { Money.new(1_00, Money::Currency.new('NZD')) }
      it { is_expected.to eq initializing_value }
    end

    context "given the initializing value doesn't respond to .to_d" do
      let(:initializing_value) { :"1" }
      it { is_expected.to eq Money.new(1) }
    end

    context 'given a currency is not provided' do
      subject(:money) { Money.new(initializing_value) }

      it "should have the default currency" do
        expect(money.currency).to eq Money.default_currency
      end
    end

    context 'given a currency is provided' do
      subject(:money) { Money.new(initializing_value, currency) }

      context 'and the currency is NZD' do
        let(:currency) { Money::Currency.new('NZD') }

        it "should have NZD currency" do
          expect(money.currency).to eq Money::Currency.new('NZD')
        end
      end

      context 'and the currency is nil' do
        let(:currency) { nil }

        it "should have the default currency" do
          expect(money.currency).to eq Money.default_currency
        end
      end
    end

    context "with infinite_precision", :infinite_precision do
      context 'given the initializing value is 1.50' do
        let(:initializing_value) { 1.50 }

        it "should have the correct cents" do
          expect(money.fractional).to eq BigDecimal('1.50')
        end
      end
    end
  end

  describe ".empty" do
    it "creates a new Money object of 0 cents" do
      expect(Money.empty).to eq Money.new(0)
    end

    it "memoizes the result" do
      expect(Money.empty.object_id).to eq Money.empty.object_id
    end

    it "memoizes a result for each currency" do
      expect(Money.empty(:cad).object_id).to eq Money.empty(:cad).object_id
    end

    it "doesn't allow money to be modified for a currency" do
      expect(Money.empty).to be_frozen
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.empty).to be_a special_money_class
    end
  end


  describe ".zero" do
    subject { Money.zero }
    it { is_expected.to eq Money.empty }

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.zero).to be_a special_money_class
    end
  end

  describe ".add_rate" do
    with_default_bank { Money::Bank::VariableExchange.new }

    it "saves rate into current bank" do
      Money.add_rate("EUR", "USD", 10)
      expect(Money.new(10_00, "EUR").exchange_to("USD")).to eq Money.new(100_00, "USD")
    end
  end

  describe ".disallow_currency_conversions!" do
    with_default_bank

    it "disallows conversions when doing money arithmetic" do
      Money.disallow_currency_conversion!
      expect { Money.new(100, "USD") + Money.new(100, "EUR") }.to raise_exception(Money::Bank::DifferentCurrencyError)
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

    it "does not round the given amount when infinite_precision is set", :infinite_precision do
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
      bank = double "bank"
      expect(Money.from_amount(1, "USD", bank).bank).to eq bank
    end

    it 'rounds using rounding_mode' do
      expect(Money.from_amount(1.999).to_d).to eq 2
      expect(Money.rounding_mode(BigDecimal::ROUND_DOWN) do
        Money.from_amount(1.999).to_d
      end).to eq 1.99
    end
  end

  %w[cents pence].each do |units|
    describe "##{units}" do
      it "is a synonym of #fractional" do
        expectation = Money.new(0)
        def expectation.fractional
          "expectation"
        end
        expect(expectation.fractional).to eq "expectation"
      end
    end
  end

  describe "#fractional" do
    it "returns the amount in fractional unit" do
      expect(Money.new(1_00).fractional).to eq 1_00
    end

    it "stores fractional as an integer regardless of what is passed into the constructor" do
      m = Money.new(100)
      expect(m.fractional).to eq 100
      expect(m.fractional).to be_a(Fixnum)
    end

    context "loading a serialized Money via YAML" do

      let(:serialized) { <<YAML
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
    mutex: !ruby/object:Mutex {}
    last_updated: 2012-11-23 20:41:47.454438399 +02:00
YAML
      }

      it "uses BigDecimal when rounding" do
        m = YAML::load serialized
        expect(m).to be_a(Money)
        expect(m.class.infinite_precision).to be false
        expect(m.fractional).to eq 250 # 249.5 rounded up
        expect(m.fractional).to be_a(Integer)
      end

      it "is a BigDecimal when using infinite_precision", :infinite_precision do
        money = YAML::load serialized
        expect(money.fractional).to be_a BigDecimal
      end
    end

    context "user changes rounding_mode" do
      with_rounding_mode BigDecimal::ROUND_HALF_EVEN

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
          expect(Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            Money.new(1.9).fractional
          end).to eq 1

          expect(Money.rounding_mode(BigDecimal::ROUND_UP) do
            Money.new(1.1).fractional
          end).to eq 2

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_EVEN
        end

        it "works for multiplication within a block" do
          Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            expect((Money.new(1_00) * "0.019".to_d).fractional).to eq 1
          end

          Money.rounding_mode(BigDecimal::ROUND_UP) do
            expect((Money.new(1_00) * "0.011".to_d).fractional).to eq 2
          end

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_EVEN
        end
      end
    end

    context "with infinite_precision", :infinite_precision do
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

    it "raises an exception if smallest denomination is not defined" do
      money = Money.new(100, "XAG")
      expect {money.round_to_nearest_cash_value}.to raise_error(Money::UndefinedSmallestDenomination)
    end

    it "returns a Fixnum when infinite_precision is not set" do
      money = Money.new(100, "USD")
      expect(money.round_to_nearest_cash_value).to be_a Fixnum
    end

    it "returns a BigDecimal when infinite_precision is set", :infinite_precision do
      money = Money.new(100, "EUR")
      expect(money.round_to_nearest_cash_value).to be_a BigDecimal
    end
  end

  describe "#amount" do
    it "returns the amount of cents as dollars" do
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

    it 'produces a BigDecimal' do
      expect(Money.new(1_00).amount).to be_a BigDecimal
    end
  end

  describe "#dollars" do
    it "is synonym of #amount" do
      m = Money.new(0)

      # Make a small expectation
      def m.amount
        5
      end

      expect(m.dollars).to eq 5
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
    it "works as documented" do
      currency = Money::Currency.new("EUR")
      expect(currency).to receive(:symbol).and_return("€")
      expect(Money.new(0, currency).symbol).to eq "€"

      currency = Money::Currency.new("EUR")
      expect(currency).to receive(:symbol).and_return(nil)
      expect(Money.new(0, currency).symbol).to eq "¤"
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
      expect(money).to eq money.to_money
      expect(money).to eq money.to_money("DKK")
      expect(money.bank).to receive(:exchange_with).with(Money.new(10_00, Money::Currency.new("DKK")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      expect(money.to_money("EUR")).to eq Money.new(200_00, "EUR")
    end
  end

  describe "#exchange_to" do
    it "exchanges the amount via its exchange bank" do
      money = Money.new(100_00, "USD")
      expect(money.bank).to receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.exchange_to("EUR")
    end

    it "exchanges the amount properly" do
      money = Money.new(100_00, "USD")
      expect(money.bank).to receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      expect(money.exchange_to("EUR")).to eq Money.new(200_00, "EUR")
    end

    it 'uses the block given as rounding method' do
      money = Money.new(100_00, 'USD')
      expect(money.bank).to receive(:exchange_with).and_yield(300_00)
      expect { |block| money.exchange_to(Money::Currency.new('EUR'), &block) }.to yield_successive_args(300_00)
    end

    it "does no exchange when the currencies are the same" do
      money = Money.new(100_00, "USD")
      expect(money.bank).to_not receive(:exchange_with)
      expect(money.exchange_to("USD")).to eq money
    end
  end

  describe "#round" do

    let(:money) { Money.new(15.75, 'NZD') }
    subject(:rounded) { money.round }

    context "without infinite_precision" do
      it "returns self (as it is already rounded)" do
        rounded = money.round
        expect(rounded).to be money
        expect(rounded.fractional).to eq 16
      end
    end

    context "with infinite_precision", :infinite_precision do
      it "returns a different money" do
        expect(rounded).not_to be money
      end

      it "rounds the cents" do
        expect(rounded.fractional).to eq 16
      end

      it "maintains the currency" do
        expect(rounded.currency).to eq Money::Currency.new('NZD')
      end

      it "uses a provided rounding strategy" do
        rounded = money.round(BigDecimal::ROUND_DOWN)
        expect(rounded.fractional).to eq 15
      end

      context "when using a subclass of Money" do
        let(:special_money_class) { Class.new(Money) }
        let(:money) { special_money_class.new(15.75, 'NZD') }

        it "preserves the class in the result" do
          expect(rounded).to be_a special_money_class
        end
      end
    end
  end

  describe "#inspect" do
    it "reports the class name properly when using inheritance" do
      expect(Money.new(1).inspect).to start_with '#<Money'
      Subclass = Class.new(Money)
      expect(Subclass.new(1).inspect).to start_with '#<Subclass'
    end
  end

  describe ".default_currency" do
    around do |ex|
      begin
        old_val = Money.default_currency
        ex.run
      ensure
        Money.default_currency = old_val
      end
    end

    it "accepts a lambda" do
      Money.default_currency = lambda { :eur }
      expect(Money.default_currency).to eq :eur
      expect(Money.new(1).currency).to eq Money::Currency.new(:eur)
    end

    it "accepts a symbol" do
      Money.default_currency = :eur
      expect(Money.default_currency).to eq Money::Currency.new(:eur)
    end
  end
end
