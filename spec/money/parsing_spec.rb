# encoding: utf-8

require "spec_helper"

describe Money do
  describe "Money.parse" do

    it "should be able to parse european-formatted inputs under 10EUR" do
      five_ninety_five = Money.new(595, 'EUR')

      Money.parse('EUR 5,95').should    == five_ninety_five
      #TODO: try and handle these
      #Money.parse('€5,95').should       == five_ninety_five
      #Money.parse('&#036;5.95').should  == five_ninety_five
    end

    it "should be able to parse european-formatted inputs with multiple thousands-seperators" do
      Money.parse('EUR 1.234.567,89').should     == Money.new(123456789, 'EUR')
      Money.parse('EUR 1.111.234.567,89').should == Money.new(111123456789, 'EUR')
    end

    it "should be able to parse USD-formatted inputs under $10" do
      five_ninety_five = Money.new(595, 'USD')

      Money.parse(5.95).should          == five_ninety_five
      Money.parse('5.95').should        == five_ninety_five
      Money.parse('$5.95').should       == five_ninety_five
      Money.parse("\n $5.95 \n").should == five_ninety_five
      Money.parse('$ 5.95').should      == five_ninety_five
      Money.parse('$5.95 ea.').should   == five_ninety_five
      Money.parse('$5.95, each').should == five_ninety_five
    end

    it "should be able to parse USD-formatted inputs with multiple thousands-seperators" do
      Money.parse('1,234,567.89').should     == Money.new(123456789, 'USD')
      Money.parse('1,111,234,567.89').should == Money.new(111123456789, 'USD')
    end

    it "should not return a price if there is a price range" do
      lambda {Money.parse('$5.95-10.95')}.should    raise_error ArgumentError
      lambda {Money.parse('$5.95 - 10.95')}.should  raise_error ArgumentError
      lambda {Money.parse('$5.95 - $10.95')}.should raise_error ArgumentError
    end

    it "should not return a price for completely invalid input" do
      # TODO: shouldn't these throw an error instead of being considered
      # equal to $0.0?
      empty_price = Money.new(0, 'USD')

      Money.parse(nil).should             == empty_price
      Money.parse('hellothere').should    == empty_price
      Money.parse('').should              == empty_price
    end
  end

  describe "Money.from_string" do
    it "converts given amount to cents" do
      Money.from_string("1").should == Money.new(1_00)
      Money.from_string("1").should == Money.new(1_00, "USD")
      Money.from_string("1", "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
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

  describe "Money.from_fixnum" do
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

  describe "Money.from_float" do
    it "converts given amount to cents" do
      Money.from_float(1.2).should == Money.new(1_20)
      Money.from_float(1.2).should == Money.new(1_20, "USD")
      Money.from_float(1.2, "EUR").should == Money.new(1_20, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
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

  describe "Money.from_bigdecimal" do
    it "converts given amount to cents" do
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00)
      Money.from_bigdecimal(BigDecimal.new("1")).should == Money.new(1_00, "USD")
      Money.from_bigdecimal(BigDecimal.new("1"), "EUR").should == Money.new(1_00, "EUR")
    end

    it "should respect :subunit_to_unit currency property" do
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

  describe "Money.from_numeric" do
    it "converts given amount to cents" do
      Money.from_numeric(1).should == Money.new(1_00)
      Money.from_numeric(1.0).should == Money.new(1_00)
      Money.from_numeric(BigDecimal.new("1")).should == Money.new(1_00)
    end

    it "should raise ArgumentError with unsupported argument" do
      lambda { Money.from_numeric("100") }.should raise_error(ArgumentError)
    end

    it "should optimize workload" do
      Money.should_receive(:from_fixnum).with(1, "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1, "USD").should == Money.new(1_00,  "USD")
      Money.should_receive(:from_bigdecimal).with(BigDecimal.new("1.0"), "USD").and_return(Money.new(1_00,  "USD"))
      Money.from_numeric(1.0, "USD").should == Money.new(1_00,  "USD")
    end

    it "should respect :subunit_to_unit currency property" do
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
end
