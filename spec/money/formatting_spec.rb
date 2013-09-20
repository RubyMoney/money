# encoding: utf-8

require "spec_helper"

describe Money, "formatting" do

  BAR = '{ "priority": 1, "iso_code": "BAR", "iso_numeric": "840", "name": "Dollar with 4 decimal places", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": "," }'
  INDIAN_BAR = '{ "priority": 1, "iso_code": "INDIAN_BAR", "iso_numeric": "840", "name": "Dollar with 4 decimal places", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "south_asian_number_formatting": true}'
  EU4 = '{ "priority": 1, "iso_code": "EU4", "iso_numeric": "841", "name": "Euro with 4 decimal places", "symbol": "€", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "€", "decimal_mark": ",", "thousands_separator": "." }'

  context "without i18n" do
    subject { Money.empty("USD") }

    its(:thousands_separator) { should == "," }
    its(:decimal_mark) { should == "." }
  end

  context "with i18n but use_i18n = false" do
    before :each do
      reset_i18n
      I18n.locale = :de
      I18n.backend.store_translations(
          :de,
          :number => { :currency => { :format => { :delimiter => ".", :separator => "," } } }
      )
      Money.use_i18n = false
    end

    after :each do
      reset_i18n
      I18n.locale = :en
      Money.use_i18n = true
    end

    subject { Money.empty("USD") }

    its(:thousands_separator) { should == "," }
    its(:decimal_mark) { should == "." }
  end

  context "with i18n" do
    after :each do
      reset_i18n
      I18n.locale = :en
    end

    context "with number.format.*" do
      before :each do
        reset_i18n
        I18n.locale = :de
        I18n.backend.store_translations(
            :de,
            :number => { :format => { :delimiter => ".", :separator => "," } }
        )
      end

      subject { Money.empty("USD") }

      its(:thousands_separator) { should == "." }
      its(:decimal_mark) { should == "," }
    end

    context "with number.currency.format.*" do
      before :each do
        reset_i18n
        I18n.locale = :de
        I18n.backend.store_translations(
            :de,
            :number => { :currency => { :format => { :delimiter => ".", :separator => "," } } }
        )
      end

      subject { Money.empty("USD") }

      its(:thousands_separator) { should == "." }
      its(:decimal_mark) { should == "," }
    end
  end

  describe "#format" do
    context "Locale :ja" do
      before { @_locale = I18n.locale; I18n.locale = :ja }

      it "formats Japanese currency in Japanese properly" do
        money = Money.new(1000, "JPY")
        money.format.should == "1,000円"
        money.format(:symbol => false).should == "1,000"
      end

      after  { I18n.locale = @_locale }
    end

    it "returns the monetary value as a string" do
      Money.ca_dollar(100).format.should == "$1.00"
      Money.new(40008).format.should == "$400.08"
    end

    it "respects :subunit_to_unit currency property" do
      Money.new(10_00, "BHD").format.should == "ب.د1.000"
    end

    it "does not display a decimal when :subunit_to_unit is 1" do
      Money.new(10_00, "CLP").format.should == "$1.000"
    end

    it "respects the thousands_separator and decimal_mark defaults" do
      one_thousand = Proc.new do |currency|
        Money.new(1000_00, currency).format
      end

      # Pounds
      one_thousand["GBP"].should == "£1,000.00"

      # Dollars
      one_thousand["USD"].should == "$1,000.00"
      one_thousand["CAD"].should == "$1,000.00"
      one_thousand["AUD"].should == "$1,000.00"
      one_thousand["NZD"].should == "$1,000.00"
      one_thousand["ZWD"].should == "$1,000.00"

      # Yen
      one_thousand["JPY"].should == "¥100,000"
      one_thousand["CNY"].should == "¥1,000.00"

      # Euro
      one_thousand["EUR"].should == "€1.000,00"

      # Rupees
      one_thousand["INR"].should == "₹1,000.00"
      one_thousand["NPR"].should == "₨1,000.00"
      one_thousand["SCR"].should == "1,000.00 ₨"
      one_thousand["LKR"].should == "1,000.00 ₨"

      # Brazilian Real
      one_thousand["BRL"].should == "R$ 1.000,00"

      # Other
      one_thousand["SEK"].should == "1 000,00 kr"
      one_thousand["GHC"].should == "₵1,000.00"
    end

    it "inserts commas into the result if the amount is sufficiently large" do
      Money.us_dollar(1_000_000_000_12).format.should == "$1,000,000,000.12"
      Money.us_dollar(1_000_000_000_12).format(:no_cents => true).should == "$1,000,000,000"
    end

    it "inserts thousands separator into the result if the amount is sufficiently large and the currency symbol is at the end" do
      Money.euro(1_234_567_12).format.should == "€1.234.567,12"
      Money.euro(1_234_567_12).format(:no_cents => true).should == "€1.234.567"
    end

    describe ":with_currency option" do
      specify "(:with_currency option => true) works as documented" do
        Money.ca_dollar(100).format(:with_currency => true).should == "$1.00 CAD"
        Money.us_dollar(85).format(:with_currency => true).should == "$0.85 USD"
      end
    end

    describe ":no_cents option" do
      specify "(:with_currency option => true) works as documented" do
        Money.ca_dollar(100).format(:no_cents => true).should == "$1"
        Money.ca_dollar(599).format(:no_cents => true).should == "$5"
        Money.ca_dollar(570).format(:no_cents => true, :with_currency => true).should == "$5 CAD"
        Money.ca_dollar(39000).format(:no_cents => true).should == "$390"
      end

      it "respects :subunit_to_unit currency property" do
        Money.new(10_00, "BHD").format(:no_cents => true).should == "ب.د1"
      end

      it "inserts thousand separators if symbol contains decimal mark and no_cents is true" do
        Money.new(100000000, "AMD").format(:no_cents => true).should == "1,000,000 դր."
        Money.new(100000000, "USD").format(:no_cents => true).should == "$1,000,000"
        Money.new(100000000, "RUB").format(:no_cents => true).should == "1.000.000 р."
      end

      it "doesn't incorrectly format HTML" do
        money = ::Money.new(1999, "RUB")
        output = money.format(:html => true, :no_cents => true)
        output.should == "19 &#x0440;&#x0443;&#x0431;"
      end
    end

    describe ":no_cents_if_whole option" do
      specify "(:no_cents_if_whole => true) works as documented" do
        Money.new(10000, "VUV").format(:no_cents_if_whole => true, :symbol => false).should == "10,000"
        Money.new(10034, "VUV").format(:no_cents_if_whole => true, :symbol => false).should == "10,034"
        Money.new(10000, "MGA").format(:no_cents_if_whole => true, :symbol => false).should == "2,000"
        Money.new(10034, "MGA").format(:no_cents_if_whole => true, :symbol => false).should == "2,006.4"
        Money.new(10000, "VND").format(:no_cents_if_whole => true, :symbol => false).should == "1.000"
        Money.new(10034, "VND").format(:no_cents_if_whole => true, :symbol => false).should == "1.003,4"
        Money.new(10000, "USD").format(:no_cents_if_whole => true, :symbol => false).should == "100"
        Money.new(10034, "USD").format(:no_cents_if_whole => true, :symbol => false).should == "100.34"
        Money.new(10000, "IQD").format(:no_cents_if_whole => true, :symbol => false).should == "10"
        Money.new(10034, "IQD").format(:no_cents_if_whole => true, :symbol => false).should == "10.034"
      end

      specify "(:no_cents_if_whole => false) works as documented" do
        Money.new(10000, "VUV").format(:no_cents_if_whole => false, :symbol => false).should == "10,000"
        Money.new(10034, "VUV").format(:no_cents_if_whole => false, :symbol => false).should == "10,034"
        Money.new(10000, "MGA").format(:no_cents_if_whole => false, :symbol => false).should == "2,000.0"
        Money.new(10034, "MGA").format(:no_cents_if_whole => false, :symbol => false).should == "2,006.4"
        Money.new(10000, "VND").format(:no_cents_if_whole => false, :symbol => false).should == "1.000,0"
        Money.new(10034, "VND").format(:no_cents_if_whole => false, :symbol => false).should == "1.003,4"
        Money.new(10000, "USD").format(:no_cents_if_whole => false, :symbol => false).should == "100.00"
        Money.new(10034, "USD").format(:no_cents_if_whole => false, :symbol => false).should == "100.34"
        Money.new(10000, "IQD").format(:no_cents_if_whole => false, :symbol => false).should == "10.000"
        Money.new(10034, "IQD").format(:no_cents_if_whole => false, :symbol => false).should == "10.034"
      end
    end

    describe ":symbol option" do
      specify "(:symbol => a symbol string) uses the given value as the money symbol" do
        Money.new(100, "GBP").format(:symbol => "£").should == "£1.00"
      end

      specify "(:symbol => true) returns symbol based on the given currency code" do
        one = Proc.new do |currency|
          Money.new(100, currency).format(:symbol => true)
        end

        # Pounds
        one["GBP"].should == "£1.00"

        # Dollars
        one["USD"].should == "$1.00"
        one["CAD"].should == "$1.00"
        one["AUD"].should == "$1.00"
        one["NZD"].should == "$1.00"
        one["ZWD"].should == "$1.00"

        # Yen
        one["JPY"].should == "¥100"
        one["CNY"].should == "¥1.00"

        # Euro
        one["EUR"].should == "€1,00"

        # Rupees
        one["INR"].should == "₹1.00"
        one["NPR"].should == "₨1.00"
        one["SCR"].should == "1.00 ₨"
        one["LKR"].should == "1.00 ₨"

        # Brazilian Real
        one["BRL"].should == "R$ 1,00"

        # Other
        one["SEK"].should == "1,00 kr"
        one["GHC"].should == "₵1.00"
      end

      specify "(:symbol => true) returns $ when currency code is not recognized" do
        currency = Money::Currency.new("EUR")
        currency.should_receive(:symbol).and_return(nil)
        Money.new(100, currency).format(:symbol => true).should == "¤1,00"
      end

      specify "(:symbol => some non-Boolean value that evaluates to true) returns symbol based on the given currency code" do
        Money.new(100, "GBP").format(:symbol => true).should == "£1.00"
        Money.new(100, "EUR").format(:symbol => true).should == "€1,00"
        Money.new(100, "SEK").format(:symbol => true).should == "1,00 kr"
      end

      specify "(:symbol => "", nil or false) returns the amount without a symbol" do
        money = Money.new(100, "GBP")
        money.format(:symbol => "").should == "1.00"
        money.format(:symbol => nil).should == "1.00"
        money.format(:symbol => false).should == "1.00"

        money = Money.new(100, "JPY")
        money.format(:symbol => false).should == "100"
      end

      it "defaults :symbol to true" do
        money = Money.new(100)
        money.format.should == "$1.00"

        money = Money.new(100, "GBP")
        money.format.should == "£1.00"

        money = Money.new(100, "EUR")
        money.format.should == "€1,00"
      end
    end

    describe ":decimal_mark option" do
      specify "(:decimal_mark => a decimal_mark string) works as documented" do
        Money.us_dollar(100).format(:decimal_mark => ",").should == "$1,00"
      end

      it "defaults to '.' if currency isn't recognized" do
        Money.new(100, "ZWD").format.should == "$1.00"
      end
    end

    describe ":separator option" do
      specify "(:separator => a separator string) works as documented" do
        Money.us_dollar(100).format(:separator  => ",").should == "$1,00"
      end
    end

    describe ":south_asian_number_formatting delimiter" do
      before(:each) do
        Money::Currency.register(JSON.parse(INDIAN_BAR, :symbolize_names => true))
      end

      after(:each) do
        Money::Currency.unregister(JSON.parse(INDIAN_BAR, :symbolize_names => true))
      end

      specify "(:south_asian_number_formatting => true) works as documented" do
        Money.new(10000000, 'INR').format(:south_asian_number_formatting => true, :symbol => false).should == "1,00,000.00"
        Money.new(1000000000, 'INDIAN_BAR').format(:south_asian_number_formatting => true, :symbol => false).should == "1,00,000.0000"
        Money.new(10000000).format(:south_asian_number_formatting => true).should == "$1,00,000.00"
      end
    end

    describe ":thousands_separator option" do
      specify "(:thousands_separator => a thousands_separator string) works as documented" do
        Money.us_dollar(100000).format(:thousands_separator => ".").should == "$1.000.00"
        Money.us_dollar(200000).format(:thousands_separator => "").should  == "$2000.00"
      end

      specify "(:thousands_separator => false or nil) works as documented" do
        Money.us_dollar(100000).format(:thousands_separator => false).should == "$1000.00"
        Money.us_dollar(200000).format(:thousands_separator => nil).should   == "$2000.00"
      end

      specify "(:delimiter => a delimiter string) works as documented" do
        Money.us_dollar(100000).format(:delimiter => ".").should == "$1.000.00"
        Money.us_dollar(200000).format(:delimiter => "").should  == "$2000.00"
      end

      specify "(:delimiter => false or nil) works as documented" do
        Money.us_dollar(100000).format(:delimiter => false).should == "$1000.00"
        Money.us_dollar(200000).format(:delimiter => nil).should   == "$2000.00"
      end

      it "defaults to ',' if currency isn't recognized" do
        Money.new(100000, "ZWD").format.should == "$1,000.00"
      end
    end

    describe ":html option" do
      specify "(:html => true) works as documented" do
        string = Money.ca_dollar(570).format(:html => true, :with_currency => true)
        string.should == "$5.70 <span class=\"currency\">CAD</span>"
      end

      specify "should fallback to symbol if entity is not available" do
        string = Money.new(570, 'DKK').format(:html => true)
        string.should == "5,70 kr"
      end
    end

    describe ":html_wrap_symbol option" do
      specify "(:html_wrap_symbol => true) works as documented" do
        string = Money.ca_dollar(570).format(:html_wrap_symbol => true)
        string.should == "<span class=\"currency_symbol\">$</span>5.70"
      end
    end


    describe ":symbol_position option" do
      it "inserts currency symbol before the amount when set to :before" do
        Money.euro(1_234_567_12).format(:symbol_position => :before).should == "€1.234.567,12"
      end

      it "inserts currency symbol after the amount when set to :after" do
        Money.us_dollar(1_000_000_000_12).format(:symbol_position => :after).should == "1,000,000,000.12 $"
      end
    end

    describe ":sign_before_symbol option" do
      specify "(:sign_before_symbol => true) works as documented" do
        Money.us_dollar(-100000).format(:sign_before_symbol => true).should == "-$1,000.00"
      end

      specify "(:sign_before_symbol => false) works as documented" do
        Money.us_dollar(-100000).format(:sign_before_symbol => false).should == "$-1,000.00"
        Money.us_dollar(-100000).format(:sign_before_symbol => nil).should == "$-1,000.00"
      end
    end

    describe ":symbol_before_without_space option" do
      it "does not insert space between currency symbol and amount when set to true" do
        Money.euro(1_234_567_12).format(:symbol_position => :before, :symbol_before_without_space => true).should == "€1.234.567,12"
      end

      it "inserts space between currency symbol and amount when set to false" do
        Money.euro(1_234_567_12).format(:symbol_position => :before, :symbol_before_without_space => false).should == "€ 1.234.567,12"
      end

      it "defaults to true" do
        Money.euro(1_234_567_12).format(:symbol_position => :before).should == "€1.234.567,12"
      end
    end

    describe ":symbol_after_without_space option" do
      it "does not insert space between amount and currency symbol when set to true" do
        Money.euro(1_234_567_12).format(:symbol_position => :after, :symbol_after_without_space => true).should == "1.234.567,12€"
      end

      it "inserts space between amount and currency symbol when set to false" do
        Money.euro(1_234_567_12).format(:symbol_position => :after, :symbol_after_without_space => false).should == "1.234.567,12 €"
      end

      it "defaults to false" do
        Money.euro(1_234_567_12).format(:symbol_position => :after).should == "1.234.567,12 €"
      end
    end

    describe ":sign_positive option" do
      specify "(:sign_positive => true, :sign_before_symbol => true) works as documented" do
        Money.us_dollar(      0).format(:sign_positive => true, :sign_before_symbol => true).should == "$0.00"
        Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => true).should == "+$1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => true).should == "-$1,000.00"
      end

      specify "(:sign_positive => true, :sign_before_symbol => false) works as documented" do
        Money.us_dollar(      0).format(:sign_positive => true, :sign_before_symbol => false).should == "$0.00"
        Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => false).should == "$+1,000.00"
        Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => nil).should == "$+1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => false).should == "$-1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => nil).should == "$-1,000.00"
      end

      specify "(:sign_positive => false, :sign_before_symbol => true) works as documented" do
        Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => true).should == "$1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => true).should == "-$1,000.00"
      end

      specify "(:sign_positive => false, :sign_before_symbol => false) works as documented" do
        Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => false).should == "$1,000.00"
        Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => nil).should == "$1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => false).should == "$-1,000.00"
        Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => nil).should == "$-1,000.00"
      end
    end

    describe ":rounded_infinite_precision option" do
      before do
        Money.infinite_precision = true
      end

      after do
        Money.infinite_precision = false
      end

      it "does round fractional when set to true" do
        Money.new(BigDecimal.new('12.1'), "USD").format(:rounded_infinite_precision => true).should == "$0.12"
        Money.new(BigDecimal.new('12.5'), "USD").format(:rounded_infinite_precision => true).should == "$0.13"
        Money.new(BigDecimal.new('123.1'), "BHD").format(:rounded_infinite_precision => true).should == "ب.د0.123"
        Money.new(BigDecimal.new('123.5'), "BHD").format(:rounded_infinite_precision => true).should == "ب.د0.124"
        Money.new(BigDecimal.new('100.1'), "USD").format(:rounded_infinite_precision => true).should == "$1.00"
        Money.new(BigDecimal.new('109.5'), "USD").format(:rounded_infinite_precision => true).should == "$1.10"
        Money.new(BigDecimal.new('1'), "MGA").format(:rounded_infinite_precision => true).should == "Ar0.2"
      end

      it "does not round fractional when set to false" do
        Money.new(BigDecimal.new('12.1'), "USD").format(:rounded_infinite_precision => false).should == "$0.121"
        Money.new(BigDecimal.new('12.5'), "USD").format(:rounded_infinite_precision => false).should == "$0.125"
        Money.new(BigDecimal.new('123.1'), "BHD").format(:rounded_infinite_precision => false).should == "ب.د0.1231"
        Money.new(BigDecimal.new('123.5'), "BHD").format(:rounded_infinite_precision => false).should == "ب.د0.1235"
        Money.new(BigDecimal.new('100.1'), "USD").format(:rounded_infinite_precision => false).should == "$1.001"
        Money.new(BigDecimal.new('109.5'), "USD").format(:rounded_infinite_precision => false).should == "$1.095"
        Money.new(BigDecimal.new('1'), "MGA").format(:rounded_infinite_precision => false).should == "Ar0.1"
      end
    end

    context "when the monetary value is 0" do
      let(:money) { Money.us_dollar(0) }

      it "returns 'free' when :display_free is true" do
        money.format(:display_free => true).should == 'free'
      end

      it "returns '$0.00' when :display_free is false or not given" do
        money.format.should == '$0.00'
        money.format(:display_free => false).should == '$0.00'
        money.format(:display_free => nil).should == '$0.00'
      end

      it "returns the value specified by :display_free if it's a string-like object" do
        money.format(:display_free => 'gratis').should == 'gratis'
      end
    end

    it "maintains floating point precision" do
      "0.01".to_money("USD").format(:symbol => false).should == "0.01"
    end

  end

  context "custom currencies with 4 decimal places" do
    before :each do
      Money::Currency.register(JSON.parse(BAR, :symbolize_names => true))
      Money::Currency.register(JSON.parse(EU4, :symbolize_names => true))
    end

    after :each do
      Money::Currency.unregister(JSON.parse(BAR, :symbolize_names => true))
      Money::Currency.unregister(JSON.parse(EU4, :symbolize_names => true))
    end

    it "respects custom subunit to unit, decimal and thousands separator" do
      Money.new(4, "BAR").format.should == "$0.0004"
      Money.new(4, "EU4").format.should == "€0,0004"

      Money.new(24, "BAR").format.should == "$0.0024"
      Money.new(24, "EU4").format.should == "€0,0024"

      Money.new(324, "BAR").format.should == "$0.0324"
      Money.new(324, "EU4").format.should == "€0,0324"

      Money.new(5324, "BAR").format.should == "$0.5324"
      Money.new(5324, "EU4").format.should == "€0,5324"

      Money.new(65324, "BAR").format.should == "$6.5324"
      Money.new(65324, "EU4").format.should == "€6,5324"

      Money.new(865324, "BAR").format.should == "$86.5324"
      Money.new(865324, "EU4").format.should == "€86,5324"

      Money.new(1865324, "BAR").format.should == "$186.5324"
      Money.new(1865324, "EU4").format.should == "€186,5324"

      Money.new(33310034, "BAR").format.should == "$3,331.0034"
      Money.new(33310034, "EU4").format.should == "€3.331,0034"

      Money.new(88833310034, "BAR").format.should == "$8,883,331.0034"
      Money.new(88833310034, "EU4").format.should == "€8.883.331,0034"
    end

  end
end

