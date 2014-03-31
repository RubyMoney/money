# encoding: utf-8

require "spec_helper"

describe Money do
  describe ".new" do
    let(:initializing_value) { 1 }
    subject(:money) { Money.new(initializing_value) }

    its(:bank) { should be Money::Bank::VariableExchange.instance }

    context 'given the initializing value is an integer' do
      let(:initializing_value) { Integer(1) }
      it 'stores the integer as the number of cents' do
        expect(money.cents).to eq initializing_value
      end
    end

    context 'given the initializing value is a float' do
      context 'and the value is 1.00' do
        let(:initializing_value) { 1.00 }
        it { should eq Money.new(1) }
      end

      context 'and the value is 1.01' do
        let(:initializing_value) { 1.01 }
        it { should eq Money.new(1) }
      end

      context 'and the value is 1.50' do
        let(:initializing_value) { 1.50 }
        it { should eq Money.new(2) }
      end
    end

    context 'given the initializing value is a rational' do
      let(:initializing_value) { Rational(1) }
      it { should eq Money.new(1) }
    end

    context 'given the initializing value is money' do
      let(:initializing_value) { Money.new(1_00, Money::Currency.new('NZD')) }
      it { should eq initializing_value }
    end

    context "given the initializing value doesn't respond to .to_d" do
      let(:initializing_value) { :"1" }
      it { should eq Money.new(1) }
    end

    context 'given a currency is not provided' do
      subject(:money) { Money.new(initializing_value) }
      its(:currency) { should eq Money.default_currency }
    end

    context 'given a currency is provided' do
      subject(:money) { Money.new(initializing_value, currency) }

      context 'and the currency is NZD' do
        let(:currency) { Money::Currency.new('NZD') }
        its(:currency) { should eq Money::Currency.new('NZD') }
      end
    end

    context "infinite_precision = true" do
      before { Money.stub(:infinite_precision => true) }
      context 'given the initializing value is 1.50' do
        let(:initializing_value) { 1.50 }
        its(:cents) { should eq BigDecimal('1.50') }
      end
    end
  end

  describe ".empty" do
    it "creates a new Money object of 0 cents" do
      Money.empty.should == Money.new(0)
    end

    it "memoizes the result" do
      Money.empty.object_id.should == Money.empty.object_id
    end

    it "memoizes a result for each currency" do
      Money.empty(:cad).object_id.should == Money.empty(:cad).object_id
    end
  end

  describe ".zero" do
    subject { Money.zero }
    it { should == Money.empty }
  end

  describe ".ca_dollar" do
    it "creates a new Money object of the given value in CAD" do
      Money.ca_dollar(50).should == Money.new(50, "CAD")
    end
  end

  describe ".us_dollar" do
    it "creates a new Money object of the given value in USD" do
      Money.us_dollar(50).should == Money.new(50, "USD")
    end
  end

  describe ".euro" do
    it "creates a new Money object of the given value in EUR" do
      Money.euro(50).should == Money.new(50, "EUR")
    end
  end

  describe ".add_rate" do
    before do
      @default_bank = Money.default_bank
      Money.default_bank = Money::Bank::VariableExchange.new
    end

    after do
      Money.default_bank = @default_bank
    end

    it "saves rate into current bank" do
      Money.add_rate("EUR", "USD", 10)
      Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
    end
  end

  describe ".disallow_currency_conversions!" do
    before do
      @default_bank = Money.default_bank
    end

    after do
      Money.default_bank = @default_bank
    end

    it "disallows conversions when doing money arithmetic" do
      Money.disallow_currency_conversion!
      expect { Money.new(100, "USD") + Money.new(100, "EUR") }.to raise_exception(Money::Bank::DifferentCurrencyError)
    end
  end

  describe "#cents" do
    it "is a synonym of #fractional" do
      expectation = Money.new(0)
      def expectation.fractional
        "expectation"
      end
      expectation.cents.should == "expectation"
    end
  end

  describe "#fractional" do
    it "returns the amount in fractional unit" do
      Money.new(1_00).fractional.should == 1_00
    end

    it "stores fractional as an integer regardless of what is passed into the constructor" do
      m = Money.new(100)
      m.fractional.should == 100
      m.fractional.should be_a(Fixnum)
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
        m.should be_a(Money)
        m.class.infinite_precision.should == false
        m.fractional.should == 250 # 249.5 rounded up
        m.fractional.should be_a(Integer)
      end

      context "with infinite_precision" do
        before do
          Money.infinite_precision = true
        end

        after do
          Money.infinite_precision = false
        end

        it "is a BigDecimal" do
          money = YAML::load serialized
          money.fractional.should be_a BigDecimal
        end
      end
    end

    context "user changes rounding_mode" do
      after do
        Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
      end

      context "with the setter" do
        it "respects the rounding_mode" do
          Money.rounding_mode = BigDecimal::ROUND_DOWN
          Money.new(1.9).fractional.should == 1

          Money.rounding_mode = BigDecimal::ROUND_UP
          Money.new(1.1).fractional.should == 2
        end
      end

      context "with a block" do
        it "respects the rounding_mode" do
          Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            Money.new(1.9).fractional
          end.should == 1

          Money.rounding_mode(BigDecimal::ROUND_UP) do
            Money.new(1.1).fractional
          end.should == 2

          Money.rounding_mode.should == BigDecimal::ROUND_HALF_EVEN
        end

        it "works for multiplication within a block" do
          Money.rounding_mode(BigDecimal::ROUND_DOWN) do
            (Money.new(1_00) * "0.019".to_d).fractional.should == 1
          end

          Money.rounding_mode(BigDecimal::ROUND_UP) do
            (Money.new(1_00) * "0.011".to_d).fractional.should == 2
          end

          Money.rounding_mode.should == BigDecimal::ROUND_HALF_EVEN
        end
      end
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "returns the amount in fractional unit" do
        Money.new(1_00).fractional.should == BigDecimal("100")
      end

      it "stores in fractional unit as an integer regardless of what is passed into the constructor" do
        m = Money.new(100)
        m.fractional.should == BigDecimal("100")
        m.fractional.should be_a(BigDecimal)
      end
    end
  end

  describe "#amount" do
    it "returns the amount of cents as dollars" do
      Money.new(1_00).amount.should == 1
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(1_00,  "USD").amount.should == 1
      Money.new(1_000, "TND").amount.should == 1
      Money.new(1,     "CLP").amount.should == 1
    end

    it "does not loose precision" do
      Money.new(100_37).amount.should == 100.37
    end

    it 'produces a BigDecimal' do
      Money.new(1_00).amount.should be_a BigDecimal
    end
  end

  describe "#dollars" do
    it "is synonym of #amount" do
      m = Money.new(0)

      # Make a small expectation
      def m.amount
        5
      end

      m.dollars.should == 5
    end
  end

  describe "#currency" do
    it "returns the currency object" do
      Money.new(1_00, "USD").currency.should == Money::Currency.new("USD")
    end
  end

  describe "#currency_as_string" do
    it "returns the iso_code of the currency object" do
      Money.new(1_00, "USD").currency_as_string.should == "USD"
      Money.new(1_00, "EUR").currency_as_string.should == "EUR"
    end
  end

  describe "#currency_as_string=" do
    it "sets the currency object using the provided string" do
      money = Money.new(100_00, "USD")
      money.currency_as_string = "EUR"
      money.currency.should == Money::Currency.new("EUR")
      money.currency_as_string = "YEN"
      money.currency.should == Money::Currency.new("YEN")
    end
  end

  describe "#hash=" do
    it "returns the same value for equal objects" do
      Money.new(1_00, "EUR").hash.should == Money.new(1_00, "EUR").hash
      Money.new(2_00, "USD").hash.should == Money.new(2_00, "USD").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(2_00, "EUR").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(1_00, "USD").hash
      Money.new(1_00, "EUR").hash.should_not == Money.new(2_00, "USD").hash
    end

    it "can be used to return the intersection of Money object arrays" do
      intersection = [Money.new(1_00, "EUR"), Money.new(1_00, "USD")] & [Money.new(1_00, "EUR")]
      intersection.should == [Money.new(1_00, "EUR")]
    end
  end

  describe "#symbol" do
    it "works as documented" do
      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return("€")
      Money.new(0, currency).symbol.should == "€"

      currency = Money::Currency.new("EUR")
      currency.should_receive(:symbol).and_return(nil)
      Money.new(0, currency).symbol.should == "¤"
    end
  end

  describe "#to_s" do
    it "works as documented" do
      Money.new(10_00).to_s.should == "10.00"
      Money.new(400_08).to_s.should == "400.08"
      Money.new(-237_43).to_s.should == "-237.43"
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").to_s.should == "1.000"
      Money.new(10_00, "CNY").to_s.should == "10.00"
    end

    it "does not have decimal when :subunit_to_unit == 1" do
      Money.new(10_00, "CLP").to_s.should == "1000"
    end

    it "does not work when :subunit_to_unit == 5" do
      Money.new(10_00, "MGA").to_s.should == "200.0"
    end

    it "respects :decimal_mark" do
      Money.new(10_00, "BRL").to_s.should == "10,00"
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "shows fractional cents" do
        Money.new(1.05, "USD").to_s.should == "0.0105"
      end

      it "suppresses fractional cents when there is none" do
        Money.new(1.0, "USD").to_s.should == "0.01"
      end

      it "shows fractional if needed when :subunut_to_unit == 1" do
        Money.new(10_00.1, "CLP").to_s.should == "1000,1"
      end
    end
  end

  describe "#to_d" do
    it "works as documented" do
      decimal = Money.new(10_00).to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 10.0
    end

    it "respects :subunit_to_unit currency property" do
      decimal = Money.new(10_00, "BHD").to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 1.0
    end

    it "works with float :subunit_to_unit currency property" do
      money = Money.new(10_00, "BHD")
      money.currency.stub(:subunit_to_unit).and_return(1000.0)

      decimal = money.to_d
      decimal.should be_a(BigDecimal)
      decimal.should == 1.0
    end
  end

  describe "#to_f" do
    it "works as documented" do
      Money.new(10_00).to_f.should == 10.0
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").to_f.should == 1.0
    end
  end

  describe "#to_money" do
    it "works as documented" do
      money = Money.new(10_00, "DKK")
      money.should == money.to_money
      money.should == money.to_money("DKK")
      money.bank.should_receive(:exchange_with).with(Money.new(10_00, Money::Currency.new("DKK")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.to_money("EUR").should == Money.new(200_00, "EUR")
    end
  end

  describe "#exchange_to" do
    it "exchanges the amount via its exchange bank" do
      money = Money.new(100_00, "USD")
      money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.exchange_to("EUR")
    end

    it "exchanges the amount properly" do
      money = Money.new(100_00, "USD")
      money.bank.should_receive(:exchange_with).with(Money.new(100_00, Money::Currency.new("USD")), Money::Currency.new("EUR")).and_return(Money.new(200_00, Money::Currency.new('EUR')))
      money.exchange_to("EUR").should == Money.new(200_00, "EUR")
    end

    it 'uses the block given as rounding method' do
      money = Money.new(100_00, 'USD')
      money.bank.should_receive(:exchange_with).and_yield(300_00)
      expect { |block| money.exchange_to(Money::Currency.new('EUR'), &block) }.to yield_successive_args(300_00)
    end

    it "does no exchange when the currencies are the same" do
      money = Money.new(100_00, "USD")
      money.bank.should_not_receive(:exchange_with)
      money.exchange_to("USD").should == money
    end
  end

  describe "#allocate" do
    it "takes no action when one gets all" do
      Money.us_dollar(005).allocate([1.0]).should == [Money.us_dollar(5)]
    end

    it "keeps currencies intact" do
      Money.ca_dollar(005).allocate([1]).should == [Money.ca_dollar(5)]
    end

    it "does not loose pennies" do
      moneys = Money.us_dollar(5).allocate([0.3, 0.7])
      moneys[0].should == Money.us_dollar(2)
      moneys[1].should == Money.us_dollar(3)
    end

    it "does not loose pennies" do
      moneys = Money.us_dollar(100).allocate([0.333, 0.333, 0.333])
      moneys[0].cents.should == 34
      moneys[1].cents.should == 33
      moneys[2].cents.should == 33
    end

    it "requires total to be less then 1" do
      expect { Money.us_dollar(0.05).allocate([0.5, 0.6]) }.to raise_error(ArgumentError)
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "allows for fractional cents allocation" do
        one_third = BigDecimal("1") / BigDecimal("3")

        moneys = Money.new(100).allocate([one_third, one_third, one_third])
        moneys[0].cents.should == one_third * BigDecimal("100")
        moneys[1].cents.should == one_third * BigDecimal("100")
        moneys[2].cents.should == one_third * BigDecimal("100")
      end
    end
  end

  describe "#split" do
    it "needs at least one party" do
      expect { Money.us_dollar(1).split(0) }.to raise_error(ArgumentError)
      expect { Money.us_dollar(1).split(-1) }.to raise_error(ArgumentError)
    end

    it "gives 1 cent to both people if we start with 2" do
      Money.us_dollar(2).split(2).should == [Money.us_dollar(1), Money.us_dollar(1)]
    end

    it "may distribute no money to some parties if there isnt enough to go around" do
      Money.us_dollar(2).split(3).should == [Money.us_dollar(1), Money.us_dollar(1), Money.us_dollar(0)]
    end

    it "does not lose pennies" do
      Money.us_dollar(5).split(2).should == [Money.us_dollar(3), Money.us_dollar(2)]
    end

    it "splits a dollar" do
      moneys = Money.us_dollar(100).split(3)
      moneys[0].cents.should == 34
      moneys[1].cents.should == 33
      moneys[2].cents.should == 33
    end

    context "infinite_precision = true" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "allows for splitting by fractional cents" do
        thirty_three_and_one_third = BigDecimal("100") / BigDecimal("3")

        moneys = Money.new(100).split(3)
        moneys[0].cents.should == thirty_three_and_one_third
        moneys[1].cents.should == thirty_three_and_one_third
        moneys[2].cents.should == thirty_three_and_one_third
      end
    end
  end

  describe "#round" do

    let(:money) { Money.new(15.75, 'NZD') }
    subject(:rounded) { money.round }

    context "without infinite_precision" do
      before do
        Money.infinite_precision = false
      end

      it "returns self (as it is already rounded)" do
        rounded = money.round
        rounded.should be money
        rounded.cents.should eq 16
      end
    end

    context "with infinite_precision" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "returns a different money" do
        rounded.should_not be money
      end

      it "rounds the cents" do
        rounded.cents.should eq 16
      end

      it "maintains the currency" do
        rounded.currency.should eq Money::Currency.new('NZD')
      end

      it "uses a provided rounding strategy" do
        rounded = money.round(BigDecimal::ROUND_DOWN)
        rounded.cents.should eq 15
      end
    end
  end

  describe "inheritance" do
    it "allows inheritance" do
      # TypeError:
      #   wrong argument type nil (expected Fixnum)
      # ./lib/money/money.rb:63:in `round'
      # ./lib/money/money.rb:63:in `fractional'
      # ./lib/money/money/arithmetic.rb:115:in `-'
      MoneyChild = Class.new(Money)
      (MoneyChild.new(1000) - Money.new(500)).should eq Money.new(500)
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
      obj.as_us_dollar.should == Money.new(1, "USD")
    end

    specify "as_ca_dollar converts Money object to CAD" do
      obj = Money.new(1, "EUR")
      obj.as_ca_dollar.should == Money.new(1, "CAD")
    end

    specify "as_euro converts Money object to EUR" do
      obj = Money.new(1, "USD")
      obj.as_euro.should == Money.new(1, "EUR")
    end
  end

  describe ".default_currency" do
    before do
      @default_currency = Money.default_currency
    end

    it "accepts a lambda" do
      Money.default_currency = lambda { :eur }
      Money.default_currency.should == Money::Currency.new(:eur)
    end

    it "accepts a symbol" do
      Money.default_currency = :eur
      Money.default_currency.should == Money::Currency.new(:eur)
    end

    after do
      Money.default_currency = @default_currency
    end
  end
end
