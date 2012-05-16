# encoding: utf-8

require "spec_helper"

describe Money, "parsing" do

  bar = '{ "priority": 1, "iso_code": "BAR", "iso_numeric": "840", "name": "Dollar with 4 decimal places", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": "," }'
  eu4 = '{ "priority": 1, "iso_code": "EU4", "iso_numeric": "841", "name": "Euro with 4 decimal places", "symbol": "€", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "€", "decimal_mark": ",", "thousands_separator": "." }'

  describe ".parse" do
    it "parses european-formatted inputs under 10EUR" do
      five_ninety_five = Money.new(595, 'EUR')

      Money.parse('EUR 5,95').should    == five_ninety_five
      #TODO: try and handle these
      #Money.parse('€5,95').should       == five_ninety_five
      #Money.parse('&#036;5.95').should  == five_ninety_five
    end

    it "parses european-formatted inputs with multiple thousands-seperators" do
      Money.parse('EUR 1.234.567,89').should     == Money.new(123456789, 'EUR')
      Money.parse('EUR 1.111.234.567,89').should == Money.new(111123456789, 'EUR')
    end

    describe 'currency assumption' do
      context 'opted in' do
        before do
          Money.assume_from_symbol = true
        end
        it "parses formatted inputs with the currency passed as a symbol" do
          Money.parse("$5.95").should == Money.new(595, 'USD')
          Money.parse("€5.95").should == Money.new(595, 'EUR')
          Money.parse(" €5.95 ").should == Money.new(595, 'EUR')
          Money.parse("£9.99").should == Money.new(999, 'GBP')
        end
        it 'should assume default currency if not a recognised symbol' do
          Money.parse("L9.99").should == Money.new(999, 'USD')
        end
       end
      context 'opted out' do
        before do
          Money.assume_from_symbol = false
        end
        it "parses formatted inputs with the currency passed as a symbol but ignores the symbol" do
          Money.parse("$5.95").should == Money.new(595, 'USD')
          Money.parse("€5.95").should == Money.new(595, 'USD')
          Money.parse(" €5.95 ").should == Money.new(595, 'USD')
          Money.parse("£9.99").should == Money.new(999, 'USD')

        end
      end
      it 'should opt out by default' do
        Money.assume_from_symbol.should be_false
      end
    end

    it "parses USD-formatted inputs under $10" do
      five_ninety_five = Money.new(595, 'USD')

      Money.parse(5.95).should          == five_ninety_five
      Money.parse('5.95').should        == five_ninety_five
      Money.parse('$5.95').should       == five_ninety_five
      Money.parse("\n $5.95 \n").should == five_ninety_five
      Money.parse('$ 5.95').should      == five_ninety_five
      Money.parse('$5.95 ea.').should   == five_ninety_five
      Money.parse('$5.95, each').should == five_ninety_five
    end

    it "parses USD-formatted inputs with multiple thousands-seperators" do
      Money.parse('1,234,567.89').should     == Money.new(123456789, 'USD')
      Money.parse('1,111,234,567.89').should == Money.new(111123456789, 'USD')
    end

    it "does not return a price if there is a price range" do
      lambda { Money.parse('$5.95-10.95') }.should    raise_error ArgumentError
      lambda { Money.parse('$5.95 - 10.95') }.should  raise_error ArgumentError
      lambda { Money.parse('$5.95 - $10.95') }.should raise_error ArgumentError
    end

    it "does not return a price for completely invalid input" do
      # TODO: shouldn't these throw an error instead of being considered
      # equal to $0.0?
      empty_price = Money.new(0, 'USD')

      Money.parse(nil).should             == empty_price
      Money.parse('hellothere').should    == empty_price
      Money.parse('').should              == empty_price
    end

    it "handles negative inputs" do
      five_ninety_five = Money.new(595, 'USD')

      Money.parse("$-5.95").should == -five_ninety_five
      Money.parse("-$5.95").should == -five_ninety_five
      Money.parse("$5.95-").should == -five_ninety_five
    end

    it "raises ArgumentError when unable to detect polarity" do
      lambda { Money.parse('-$5.95-') }.should raise_error ArgumentError
    end

    it "parses correctly strings with exactly 3 decimal digits" do
      Money.parse("6,534", "EUR").should == Money.new(653, "EUR")
    end

    context "custom currencies with 4 decimal places" do
      before :each do
        Money::Currency.register(MultiJson.load(bar, :symbolize_keys => true))
        Money::Currency.register(MultiJson.load(eu4, :symbolize_keys => true))
      end

      # String#to_money(Currency) is equivalent to Money.parse(String, Currency)
      it "parses strings respecting subunit to unit, decimal and thousands separator" do
        "$0.4".to_money("BAR").should == Money.new(4000, "BAR")
        "€0,4".to_money("EU4").should == Money.new(4000, "EU4")

        "$0.04".to_money("BAR").should == Money.new(400, "BAR")
        "€0,04".to_money("EU4").should == Money.new(400, "EU4")

        "$0.004".to_money("BAR").should == Money.new(40, "BAR")
        "€0,004".to_money("EU4").should == Money.new(40, "EU4")

        "$0.0004".to_money("BAR").should == Money.new(4, "BAR")
        "€0,0004".to_money("EU4").should == Money.new(4, "EU4")

        "$0.0024".to_money("BAR").should == Money.new(24, "BAR")
        "€0,0024".to_money("EU4").should == Money.new(24, "EU4")

        "$0.0324".to_money("BAR").should == Money.new(324, "BAR")
        "€0,0324".to_money("EU4").should == Money.new(324, "EU4")

        "$0.5324".to_money("BAR").should == Money.new(5324, "BAR")
        "€0,5324".to_money("EU4").should == Money.new(5324, "EU4")

        "$6.5324".to_money("BAR").should == Money.new(65324, "BAR")
        "€6,5324".to_money("EU4").should == Money.new(65324, "EU4")

        "$86.5324".to_money("BAR").should == Money.new(865324, "BAR")
        "€86,5324".to_money("EU4").should == Money.new(865324, "EU4")

        "$186.5324".to_money("BAR").should == Money.new(1865324, "BAR")
        "€186,5324".to_money("EU4").should == Money.new(1865324, "EU4")

        "$3,331.0034".to_money("BAR").should == Money.new(33310034, "BAR")
        "€3.331,0034".to_money("EU4").should == Money.new(33310034, "EU4")

        "$8,883,331.0034".to_money("BAR").should == Money.new(88833310034, "BAR")
        "€8.883.331,0034".to_money("EU4").should == Money.new(88833310034, "EU4")
      end
    end
  end

  describe ".from_string" do
    it "converts given amount to cents" do
      Money.from_string("1").should == Money.new(1_00)
      Money.from_string("1").should == Money.new(1_00, "USD")
      Money.from_string("1", "EUR").should == Money.new(1_00, "EUR")
    end

    it "respects :subunit_to_unit currency property" do
      Money.from_string("1", "USD").should == Money.new(1_00,  "USD")
      Money.from_string("1", "TND").should == Money.new(1_000, "TND")
      Money.from_string("1", "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_string("1")
      m.currency.should == Money.default_currency

      m = Money.from_string("1", Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_string("1", "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe ".from_fixnum" do
    it "converts given amount to cents" do
      Money.from_fixnum(1).should == Money.new(1_00)
      Money.from_fixnum(1).should == Money.new(1_00, "USD")
      Money.from_fixnum(1, "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
      Money.from_fixnum(1, "USD").should == Money.new(1_00,  "USD")
      Money.from_fixnum(1, "TND").should == Money.new(1_000, "TND")
      Money.from_fixnum(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_fixnum(1)
      m.currency.should == Money.default_currency

      m = Money.from_fixnum(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_fixnum(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe ".from_float" do
    it "converts given amount to cents" do
      Money.from_float(1.2).should == Money.new(1_20)
      Money.from_float(1.2).should == Money.new(1_20, "USD")
      Money.from_float(1.2, "EUR").should == Money.new(1_20, "EUR")
    end

    it "respects :subunit_to_unit currency property" do
      Money.from_float(1.2, "USD").should == Money.new(1_20,  "USD")
      Money.from_float(1.2, "TND").should == Money.new(1_200, "TND")
      Money.from_float(1.2, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_float(1.2)
      m.currency.should == Money.default_currency

      m = Money.from_float(1.2, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_float(1.2, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe ".from_bigdecimal" do
    it "converts given amount to cents" do
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00)
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00, "USD")
      Money.from_bigdecimal(BigDecimal.new("1"), "EUR").should == Money.new(1_00, "EUR")
    end

    it "respects :subunit_to_unit currency property" do
      Money.from_bigdecimal(BigDecimal.new("1"), "USD").should == Money.new(1_00,  "USD")
      Money.from_bigdecimal(BigDecimal.new("1"), "TND").should == Money.new(1_000, "TND")
      Money.from_bigdecimal(BigDecimal.new("1"), "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a currency options" do
      m = Money.from_bigdecimal(BigDecimal.new("1"))
      m.currency.should == Money.default_currency

      m = Money.from_bigdecimal(BigDecimal.new("1"), Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_bigdecimal(BigDecimal.new("1"), "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe ".from_numeric" do
    it "converts given amount to cents" do
      Money.from_numeric(1).should == Money.new(1_00)
      Money.from_numeric(1.0).should == Money.new(1_00)
      Money.from_numeric(BigDecimal.new("1")).should == Money.new(1_00)
    end

    it "raises ArgumentError with unsupported argument" do
      lambda { Money.from_numeric("100") }.should raise_error(ArgumentError)
    end

    it "optimizes workload" do
      Money.should_receive(:from_fixnum).with(1, "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1, "USD").should == Money.new(1_00,  "USD")
      Money.should_receive(:from_bigdecimal).with(BigDecimal.new("1.0"), "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1.0, "USD").should == Money.new(1_00,  "USD")
    end

    it "respects :subunit_to_unit currency property" do
      Money.from_numeric(1, "USD").should == Money.new(1_00,  "USD")
      Money.from_numeric(1, "TND").should == Money.new(1_000, "TND")
      Money.from_numeric(1, "CLP").should == Money.new(1,     "CLP")
    end

    it "accepts a bank option" do
      Money.from_numeric(1).should == Money.new(1_00)
      Money.from_numeric(1).should == Money.new(1_00, "USD")
      Money.from_numeric(1, "EUR").should == Money.new(1_00, "EUR")
    end

    it "accepts a currency options" do
      m = Money.from_numeric(1)
      m.currency.should == Money.default_currency

      m = Money.from_numeric(1, Money::Currency.wrap("EUR"))
      m.currency.should == Money::Currency.wrap("EUR")

      m = Money.from_numeric(1, "EUR")
      m.currency.should == Money::Currency.wrap("EUR")
    end
  end

  describe ".extract_cents" do
    it "correctly treats pipe marks '|' in input (regression test)" do
      Money.extract_cents('100|0').should == Money.extract_cents('100!0')
    end
  end

  context "given the same inputs to .parse and .from_*" do
    it "gives the same results" do
      4.635.to_money.should == "4.635".to_money
    end
  end

end
