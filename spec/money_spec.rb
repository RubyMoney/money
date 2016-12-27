# encoding: utf-8

describe Money do
  describe ".new" do
    let(:initializing_value) { 1 }
    subject(:money) { Money.new(initializing_value) }

    it "should be an instance of `Money::Bank::VariableExchange`" do
      expect(money.bank).to be Money::Bank::VariableExchange.instance
    end

    it 'stores the integer as the number of cents' do
      expect(money.to_d).to eq initializing_value
    end

    context 'given the initializing value is a float' do
      context 'and the value is 1.00' do
        let(:initializing_value) { 1.00 }
        it { is_expected.to eq Money.new(1) }
      end

      context 'and the value is 1.01' do
        let(:initializing_value) { 0.0101 }
        it { is_expected.to eq Money.new(0.01) }
      end

      context 'and the value is 1.50' do
        let(:initializing_value) { 0.015 }
        it { is_expected.to eq Money.new(0.02) }
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
          expect(money.to_d).to eq '1.50'.to_d
        end
      end
    end
  end

  describe ".empty" do
    it "creates a new Money object of 0 cents" do
      expect(Money.empty).to eq Money.new(0)
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
      expect { Money.new(100, "USD") + Money.new(100, "EUR") }.
        to raise_exception(Money::Bank::DifferentCurrencyError)
    end
  end

  describe '.from_subunits' do
    subject { ->(*args) { described_class.from_subunits(*args) } }
    it 'accepts numeric values' do
      expect(subject.call(1, 'USD')).to eq Money.usd(0.01)
      expect(subject.call(1.0, 'USD')).to eq Money.usd(0.01)
      expect(subject.call('1'.to_d, 'USD')).to eq Money.usd(0.01)
    end

    it 'raises ArgumentError with unsupported argument' do
      # expect { subject.call('asd') }.to raise_error(ArgumentError)
      expect { subject.call(Object.new) }.to raise_error(ArgumentError)
    end

    it 'converts given amount to subunits according to currency' do
      expect(subject.call(1, 'USD')).to eq Money.new(0.01, 'USD')
      expect(subject.call(1, 'TND')).to eq Money.new(0.001, 'TND')
      expect(subject.call(1, 'JPY')).to eq Money.new(1, 'JPY')
    end

    it 'rounds given' do
      expect(subject.call(44.4, 'USD').amount).to eq '0.44'.to_d
      expect(subject.call(55.5, 'USD').amount).to eq '0.56'.to_d
      expect(subject.call(444.4, 'JPY').amount).to eq '444'.to_d
      expect(subject.call(555.5, 'JPY').amount).to eq '556'.to_d
    end

    it 'does not round the given amount when infinite_precision is set', :infinite_precision do
      expect(subject.call(4.444, 'USD').amount).to eq '0.04444'.to_d
      expect(subject.call(5.555, 'USD').amount).to eq '0.05555'.to_d
      expect(subject.call(444.4, 'JPY').amount).to eq '444.4'.to_d
      expect(subject.call(555.5, 'JPY').amount).to eq '555.5'.to_d
    end

    it 'accepts an optional currency' do
      expect(subject.call(1).currency).to eq Money.default_currency
      jpy = Money::Currency.wrap('JPY')
      expect(subject.call(1, jpy).currency).to eq jpy
      expect(subject.call(1, 'JPY').currency).to eq jpy
    end

    it 'accepts an optional bank' do
      expect(subject.call(1).bank).to eq Money.default_bank
      bank = double(:bank)
      expect(subject.call(1, 'USD', bank).bank).to eq bank
    end

    it 'rounds using rounding_mode' do
      expect(subject.call(199.9, 'USD').to_d).to eq 2
      Money.rounding_mode(BigDecimal::ROUND_DOWN) do
        expect(subject.call(199.9).to_d).to eq 1.99
      end
    end
  end

  describe "#fractional" do
    it "returns the amount in fractional unit" do
      expect(Money.new(1).fractional).to eq 1_00
    end

    it "stores fractional as an integer regardless of what is passed into the constructor" do
      m = Money.new(1)
      expect(m.fractional).to eq 100
      expect(m.fractional).to be_a(Fixnum)
    end

    context "loading a serialized Money via YAML" do

      let(:serialized) { <<-YAML
!ruby/object:Money
  amount: 2.495
  currency: !ruby/object:Money::Currency
    id: :eur
    priority: 2
    code: EUR
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
          expect(Money.new(0.019).fractional).to eq 1

          Money.rounding_mode = BigDecimal::ROUND_UP
          expect(Money.new(0.011).fractional).to eq 2
        end
      end

      context "with a block" do
        it "respects the rounding_mode" do
          expect(Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            Money.new(0.019).fractional
          end).to eq 1

          expect(Money.rounding_mode(BigDecimal::ROUND_UP) do
            Money.new(0.011).fractional
          end).to eq 2

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_EVEN
        end

        it "works for multiplication within a block" do
          Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            expect((Money.new(1) * '0.019'.to_d).fractional).to eq 1
          end

          Money.rounding_mode(BigDecimal::ROUND_UP) do
            expect((Money.new(1) * '0.011'.to_d).fractional).to eq 2
          end

          expect(Money.rounding_mode).to eq BigDecimal::ROUND_HALF_EVEN
        end
      end
    end

    context "with infinite_precision", :infinite_precision do
      it "returns the amount in fractional unit" do
        expect(Money.new(1).fractional).to eq 100.to_d
      end

      it "stores in fractional unit as an integer regardless of what is passed into the constructor" do
        m = Money.new(1)
        expect(m.fractional).to eq 100.to_d
        expect(m.fractional).to be_a(BigDecimal)
      end
    end
  end

  describe '#round_to_nearest_cash_value' do
    subject { ->(x) { x.round_to_nearest_cash_value } }

    it 'rounds to the nearest possible cash value' do
      expect(subject.call Money.new(  23.50, 'AED')).to eq( 23.50)
      expect(subject.call Money.new( -23.50, 'AED')).to eq(-23.50)
      expect(subject.call Money.new(  22.13, 'AED')).to eq( 22.25)
      expect(subject.call Money.new( -22.13, 'AED')).to eq(-22.25)
      expect(subject.call Money.new(  22.12, 'AED')).to eq( 22.00)
      expect(subject.call Money.new( -22.12, 'AED')).to eq(-22.00)
      expect(subject.call Money.new(   1.78, 'CHF')).to eq( 1.80)
      expect(subject.call Money.new(  -1.78, 'CHF')).to eq(-1.80)
      expect(subject.call Money.new(   1.77, 'CHF')).to eq( 1.75)
      expect(subject.call Money.new(  -1.77, 'CHF')).to eq(-1.75)
      expect(subject.call Money.new(   1.75, 'CHF')).to eq( 1.75)
      expect(subject.call Money.new(  -1.75, 'CHF')).to eq(-1.75)
      expect(subject.call Money.new(   2.99, 'USD')).to eq( 2.99)
      expect(subject.call Money.new(  -2.99, 'USD')).to eq(-2.99)
      expect(subject.call Money.new(   3.00, 'USD')).to eq( 3.00)
      expect(subject.call Money.new(  -3.00, 'USD')).to eq(-3.00)
      expect(subject.call Money.new(   3.01, 'USD')).to eq( 3.01)
      expect(subject.call Money.new(  -3.01, 'USD')).to eq(-3.01)
    end

    it 'raises an exception if smallest denomination is not defined' do
      expect { subject.call Money.new(100, 'XAG') }.
        to raise_error(Money::UndefinedSmallestDenomination)
    end

    it 'returns a BigDecimal' do
      expect(subject.call Money.new(100, 'USD')).to be_a BigDecimal
    end
  end

  describe '#amount' do
    it 'returns the amount of cents as dollars' do
      expect(Money.new(1).amount).to eq 1
    end

    it 'respects :subunit_to_unit currency property' do
      expect(Money.new(1, 'USD').amount).to eq 1
      expect(Money.new(1, 'TND').amount).to eq 1
      expect(Money.new(1, 'VUV').amount).to eq 1
      expect(Money.new(1, 'CLP').amount).to eq 1
    end

    it 'does not lose precision' do
      expect(Money.new(100.37).amount).to eq 100.37
    end

    it 'produces a BigDecimal' do
      expect(Money.new(1).amount).to be_a BigDecimal
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
      decimal = Money.new(10).to_d
      expect(decimal).to be_a(BigDecimal)
      expect(decimal).to eq 10.0
    end

    it "respects :subunit_to_unit currency property" do
      decimal = Money.new(1, "BHD").to_d
      expect(decimal).to be_a(BigDecimal)
      expect(decimal).to eq 1.0
    end
  end

  describe "#to_i" do
    it "works as documented" do
      expect(Money.usd(10).to_i).to eq 10
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(1, 'BHD').to_i).to eq 1
    end
  end

  describe '#to_money' do
    it 'works as documented' do
      money = Money.new(10_00, 'DKK')
      expect(money).to eq money.to_money
      expect(money).to eq money.to_money('DKK')
      expect(money.bank).to receive(:exchange_with).
        with(money, Money::Currency.new('EUR')) { Money.new(200_00, 'EUR') }
      expect(money.to_money('EUR')).to eq Money.new(200_00, 'EUR')
    end
  end

  describe '#exchange_to' do
    it 'exchanges the amount via its exchange bank' do
      money = Money.new(100_00, 'USD')
      expect(money.bank).to receive(:exchange_with).
        with(money, Money::Currency.new('EUR')) { Money.new(200_00, 'EUR') }
      money.exchange_to('EUR')
    end

    it 'exchanges the amount properly' do
      money = Money.new(100_00, 'USD')
      expect(money.bank).to receive(:exchange_with).
        with(money, Money::Currency.new('EUR')) { Money.new(200_00, 'EUR') }
      expect(money.exchange_to('EUR')).to eq Money.new(200_00, 'EUR')
    end

    it 'uses the block given as rounding method' do
      money = Money.new(100_00, 'USD')
      expect(money.bank).to receive(:exchange_with).and_yield(300_00)
      expect { |block| money.exchange_to('EUR', &block) }.to yield_successive_args(300_00)
    end

    it 'does no exchange when the currencies are the same' do
      money = Money.new(100_00, 'USD')
      expect(money.bank).to_not receive(:exchange_with)
      expect(money.exchange_to('USD')).to eq money
    end
  end

  describe "#round" do
    let(:money) { Money.new(0.1575, 'NZD') }
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
    with_default_currency Money.default_currency

    it "accepts a lambda" do
      Money.default_currency = lambda { Money::Currency.new(:eur) }
      expect(Money.default_currency).to eq :eur
      expect(Money.new(1).currency).to eq Money::Currency.new(:eur)
    end

    it "accepts a symbol" do
      Money.default_currency = :eur
      expect(Money.default_currency).to eq Money::Currency.new(:eur)
    end
  end
end
