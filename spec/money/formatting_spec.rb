# encoding: utf-8

describe Money, "formatting" do

  BAR = '{ "priority": 1, "iso_code": "BAR", "iso_numeric": "840", "name": "Dollar with 4 decimal places", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "smallest_denomination": 1 }'
  INDIAN_BAR = '{ "priority": 1, "iso_code": "INDIAN_BAR", "iso_numeric": "840", "name": "Dollar with 4 decimal places", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "south_asian_number_formatting": true, "smallest_denomination": 1}'
  EU4 = '{ "priority": 1, "iso_code": "EU4", "iso_numeric": "841", "name": "Euro with 4 decimal places", "symbol": "€", "subunit": "Cent", "subunit_to_unit": 10000, "symbol_first": true, "html_entity": "€", "decimal_mark": ",", "thousands_separator": ".", "smallest_denomination": 1 }'

  context "without i18n" do
    subject(:money) { Money.empty("USD") }

    it "should use ',' as the thousands separator" do
      expect(money.thousands_separator).to eq ','
    end

    it "should use '.' as the decimal mark" do
      expect(money.decimal_mark).to eq '.'
    end
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

    subject(:money) { Money.empty("USD") }

    it "should use ',' as the thousands separator" do
      expect(money.thousands_separator).to eq ','
    end

    it "should use '.' as the decimal mark" do
      expect(money.decimal_mark).to eq '.'
    end
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

      subject(:money) { Money.empty("USD") }

      it "should use '.' as the thousands separator" do
        expect(money.thousands_separator).to eq '.'
      end

      it "should use ',' as the decimal mark" do
        expect(money.decimal_mark).to eq ','
      end
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

      subject(:money) { Money.empty("USD") }

      it "should use '.' as the thousands separator" do
        expect(money.thousands_separator).to eq '.'
      end

      it "should use ',' as the decimal mark" do
        expect(money.decimal_mark).to eq ','
      end
    end

    context "with number.currency.symbol.*" do
      before :each do
        reset_i18n
        I18n.locale = :de
        I18n.backend.store_translations(
            :de,
            :number => { :currency => { :symbol => { :CAD => "CAD$" } } }
        )
      end

      subject(:money) { Money.empty("CAD") }

      it "should use 'CAD$' as the currency symbol" do
        expect(money.format(:translate => true)).to eq("CAD$0.00")
      end
    end
  end

  describe "#format" do
    context "Locale :ja" do
      before { @_locale = I18n.locale; I18n.locale = :ja }

      it "formats Japanese currency in Japanese properly" do
        money = Money.new(1000, "JPY")
        expect(money.format).to eq "1,000円"
        expect(money.format(:symbol => false)).to eq "1,000"
      end

      after  { I18n.locale = @_locale }
    end

    it "returns the monetary value as a string" do
      expect(Money.ca_dollar(100).format).to eq "$1.00"
      expect(Money.new(40008).format).to eq "$400.08"
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(10_00, "BHD").format).to eq "ب.د1.000"
    end

    it "does not display a decimal when :subunit_to_unit is 1" do
      expect(Money.new(10_00, "VUV").format).to eq "Vt1,000"
    end

    it "respects the thousands_separator and decimal_mark defaults" do
      one_thousand = Proc.new do |currency|
        Money.new(1000_00, currency).format
      end

      # Pounds
      expect(one_thousand["GBP"]).to eq "£1,000.00"

      # Dollars
      expect(one_thousand["USD"]).to eq "$1,000.00"
      expect(one_thousand["CAD"]).to eq "$1,000.00"
      expect(one_thousand["AUD"]).to eq "$1,000.00"
      expect(one_thousand["NZD"]).to eq "$1,000.00"
      expect(one_thousand["ZWD"]).to eq "$1,000.00"

      # Yen
      expect(one_thousand["JPY"]).to eq "¥100,000"
      expect(one_thousand["CNY"]).to eq "¥1,000.00"

      # Euro
      expect(one_thousand["EUR"]).to eq "€1.000,00"

      # Rupees
      expect(one_thousand["INR"]).to eq "₹1,000.00"
      expect(one_thousand["NPR"]).to eq "₨1,000.00"
      expect(one_thousand["SCR"]).to eq "1,000.00 ₨"
      expect(one_thousand["LKR"]).to eq "1,000.00 ₨"

      # Brazilian Real
      expect(one_thousand["BRL"]).to eq "R$1.000,00"

      # Other
      expect(one_thousand["SEK"]).to eq "1 000,00 kr"
      expect(one_thousand["GHC"]).to eq "₵1,000.00"
    end

    it "inserts commas into the result if the amount is sufficiently large" do
      expect(Money.us_dollar(1_000_000_000_12).format).to eq "$1,000,000,000.12"
      expect(Money.us_dollar(1_000_000_000_12).format(:no_cents => true)).to eq "$1,000,000,000"
    end

    it "inserts thousands separator into the result if the amount is sufficiently large and the currency symbol is at the end" do
      expect(Money.euro(1_234_567_12).format).to eq "€1.234.567,12"
      expect(Money.euro(1_234_567_12).format(:no_cents => true)).to eq "€1.234.567"
    end

    context 'when default_formatting_rules defines (display_free: true)' do
      before do
        Money.default_formatting_rules = { :display_free => "you won't pay a thing" }
      end

      after do
        Money.default_formatting_rules = nil
      end

      context 'with no rule provided' do
        it 'acknowledges default rule' do
          expect(Money.new(0, 'USD').format).to eq "you won't pay a thing"
        end
      end

      context 'with rule (display_free: false) provided' do
        it 'acknowledges provided rule' do
          expect(Money.new(0, 'USD').format(:display_free => false)).to eq '$0.00'
        end
      end
    end

    context 'when default_formatting_rules is not defined' do
      before do
        Money.default_formatting_rules = nil
      end

      context 'acknowledges provided rule' do
        it 'acknowledges provided rule' do
          expect(Money.new(100, 'USD').format(:with_currency => true)).to eq '$1.00 USD'
        end
      end
    end

    describe ":with_currency option" do
      specify "(:with_currency option => true) works as documented" do
        expect(Money.ca_dollar(100).format(:with_currency => true)).to eq "$1.00 CAD"
        expect(Money.us_dollar(85).format(:with_currency => true)).to eq "$0.85 USD"
      end
    end

    describe ":no_cents option" do
      specify "(:with_currency option => true) works as documented" do
        expect(Money.ca_dollar(100).format(:no_cents => true)).to eq "$1"
        expect(Money.ca_dollar(599).format(:no_cents => true)).to eq "$5"
        expect(Money.ca_dollar(570).format(:no_cents => true, :with_currency => true)).to eq "$5 CAD"
        expect(Money.ca_dollar(39000).format(:no_cents => true)).to eq "$390"
      end

      it "respects :subunit_to_unit currency property" do
        expect(Money.new(10_00, "BHD").format(:no_cents => true)).to eq "ب.د1"
      end

      it "inserts thousand separators if symbol contains decimal mark and no_cents is true" do
        expect(Money.new(100000000, "AMD").format(:no_cents => true)).to eq "1,000,000 դր."
        expect(Money.new(100000000, "USD").format(:no_cents => true)).to eq "$1,000,000"
        expect(Money.new(100000000, "RUB").format(:no_cents => true)).to eq "1.000.000 ₽"
      end

      it "doesn't incorrectly format HTML" do
        money = ::Money.new(1999, "RUB")
        output = money.format(:html => true, :no_cents => true)
        expect(output).to eq "19 &#x20BD;"
      end
    end

    describe ":no_cents_if_whole option" do
      specify "(:no_cents_if_whole => true) works as documented" do
        expect(Money.new(10000, "VUV").format(:no_cents_if_whole => true, :symbol => false)).to eq "10,000"
        expect(Money.new(10034, "VUV").format(:no_cents_if_whole => true, :symbol => false)).to eq "10,034"
        expect(Money.new(10000, "MGA").format(:no_cents_if_whole => true, :symbol => false)).to eq "2,000"
        expect(Money.new(10034, "MGA").format(:no_cents_if_whole => true, :symbol => false)).to eq "2,006.4"
        expect(Money.new(10000, "VND").format(:no_cents_if_whole => true, :symbol => false)).to eq "10.000"
        expect(Money.new(10034, "VND").format(:no_cents_if_whole => true, :symbol => false)).to eq "10.034"
        expect(Money.new(10000, "USD").format(:no_cents_if_whole => true, :symbol => false)).to eq "100"
        expect(Money.new(10034, "USD").format(:no_cents_if_whole => true, :symbol => false)).to eq "100.34"
        expect(Money.new(10000, "IQD").format(:no_cents_if_whole => true, :symbol => false)).to eq "10"
        expect(Money.new(10034, "IQD").format(:no_cents_if_whole => true, :symbol => false)).to eq "10.034"
      end

      specify "(:no_cents_if_whole => false) works as documented" do
        expect(Money.new(10000, "VUV").format(:no_cents_if_whole => false, :symbol => false)).to eq "10,000"
        expect(Money.new(10034, "VUV").format(:no_cents_if_whole => false, :symbol => false)).to eq "10,034"
        expect(Money.new(10000, "MGA").format(:no_cents_if_whole => false, :symbol => false)).to eq "2,000.0"
        expect(Money.new(10034, "MGA").format(:no_cents_if_whole => false, :symbol => false)).to eq "2,006.4"
        expect(Money.new(10000, "VND").format(:no_cents_if_whole => false, :symbol => false)).to eq "10.000"
        expect(Money.new(10034, "VND").format(:no_cents_if_whole => false, :symbol => false)).to eq "10.034"
        expect(Money.new(10000, "USD").format(:no_cents_if_whole => false, :symbol => false)).to eq "100.00"
        expect(Money.new(10034, "USD").format(:no_cents_if_whole => false, :symbol => false)).to eq "100.34"
        expect(Money.new(10000, "IQD").format(:no_cents_if_whole => false, :symbol => false)).to eq "10.000"
        expect(Money.new(10034, "IQD").format(:no_cents_if_whole => false, :symbol => false)).to eq "10.034"
      end
    end

    describe ":symbol option" do
      specify "(:symbol => a symbol string) uses the given value as the money symbol" do
        expect(Money.new(100, "GBP").format(:symbol => "£")).to eq "£1.00"
      end

      specify "(:symbol => true) returns symbol based on the given currency code" do
        one = Proc.new do |currency|
          Money.new(100, currency).format(:symbol => true)
        end

        # Pounds
        expect(one["GBP"]).to eq "£1.00"

        # Dollars
        expect(one["USD"]).to eq "$1.00"
        expect(one["CAD"]).to eq "$1.00"
        expect(one["AUD"]).to eq "$1.00"
        expect(one["NZD"]).to eq "$1.00"
        expect(one["ZWD"]).to eq "$1.00"

        # Yen
        expect(one["JPY"]).to eq "¥100"
        expect(one["CNY"]).to eq "¥1.00"

        # Euro
        expect(one["EUR"]).to eq "€1,00"

        # Rupees
        expect(one["INR"]).to eq "₹1.00"
        expect(one["NPR"]).to eq "₨1.00"
        expect(one["SCR"]).to eq "1.00 ₨"
        expect(one["LKR"]).to eq "1.00 ₨"

        # Brazilian Real
        expect(one["BRL"]).to eq "R$1,00"

        # Other
        expect(one["SEK"]).to eq "1,00 kr"
        expect(one["GHC"]).to eq "₵1.00"
      end

      specify "(:symbol => true) returns $ when currency code is not recognized" do
        currency = Money::Currency.new("EUR")
        expect(currency).to receive(:symbol).and_return(nil)
        expect(Money.new(100, currency).format(:symbol => true)).to eq "¤1,00"
      end

      specify "(:symbol => some non-Boolean value that evaluates to true) returns symbol based on the given currency code" do
        expect(Money.new(100, "GBP").format(:symbol => true)).to eq "£1.00"
        expect(Money.new(100, "EUR").format(:symbol => true)).to eq "€1,00"
        expect(Money.new(100, "SEK").format(:symbol => true)).to eq "1,00 kr"
      end

      specify "(:symbol => "", nil or false) returns the amount without a symbol" do
        money = Money.new(100, "GBP")
        expect(money.format(:symbol => "")).to eq "1.00"
        expect(money.format(:symbol => nil)).to eq "1.00"
        expect(money.format(:symbol => false)).to eq "1.00"

        money = Money.new(100, "JPY")
        expect(money.format(:symbol => false)).to eq "100"
      end

      it "defaults :symbol to true" do
        money = Money.new(100)
        expect(money.format).to eq "$1.00"

        money = Money.new(100, "GBP")
        expect(money.format).to eq "£1.00"

        money = Money.new(100, "EUR")
        expect(money.format).to eq "€1,00"
      end

      specify "(:symbol => false) returns a signed amount without a symbol" do
        money = Money.new(-100, "EUR")
        expect(money.format(:symbol => false)).to eq "-1,00"

        money = Money.new(100, "EUR")
        expect(money.format(:symbol => false,
                     :sign_positive => true)).to eq "+1,00"
      end
    end

    describe ":decimal_mark option" do
      specify "(:decimal_mark => a decimal_mark string) works as documented" do
        expect(Money.us_dollar(100).format(:decimal_mark => ",")).to eq "$1,00"
      end

      it "defaults to '.' if currency isn't recognized" do
        expect(Money.new(100, "ZWD").format).to eq "$1.00"
      end
    end

    describe ":separator option" do
      specify "(:separator => a separator string) works as documented" do
        expect(Money.us_dollar(100).format(:separator  => ",")).to eq "$1,00"
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
        expect(Money.new(10000000, 'INR').format(:south_asian_number_formatting => true, :symbol => false)).to eq "1,00,000.00"
        expect(Money.new(1000000000, 'INDIAN_BAR').format(:south_asian_number_formatting => true, :symbol => false)).to eq "1,00,000.0000"
        expect(Money.new(10000000).format(:south_asian_number_formatting => true)).to eq "$1,00,000.00"
      end
    end

    describe ":thousands_separator option" do
      specify "(:thousands_separator => a thousands_separator string) works as documented" do
        expect(Money.us_dollar(100000).format(:thousands_separator => ".")).to eq "$1.000.00"
        expect(Money.us_dollar(200000).format(:thousands_separator => "")).to eq "$2000.00"
      end

      specify "(:thousands_separator => false or nil) works as documented" do
        expect(Money.us_dollar(100000).format(:thousands_separator => false)).to eq "$1000.00"
        expect(Money.us_dollar(200000).format(:thousands_separator => nil)).to eq "$2000.00"
      end

      specify "(:delimiter => a delimiter string) works as documented" do
        expect(Money.us_dollar(100000).format(:delimiter => ".")).to eq "$1.000.00"
        expect(Money.us_dollar(200000).format(:delimiter => "")).to eq "$2000.00"
      end

      specify "(:delimiter => false or nil) works as documented" do
        expect(Money.us_dollar(100000).format(:delimiter => false)).to eq "$1000.00"
        expect(Money.us_dollar(200000).format(:delimiter => nil)).to eq "$2000.00"
      end

      it "defaults to ',' if currency isn't recognized" do
        expect(Money.new(100000, "ZWD").format).to eq "$1,000.00"
      end
    end

    describe ":thousands_separator and :decimal_mark option" do
      specify "(:thousands_separator => a thousands_separator string, :decimal_mark => a decimal_mark string) works as documented" do
        expect(Money.new(123_456_789, "USD").format(thousands_separator: ".", decimal_mark: ",")).to eq("$1.234.567,89")
        expect(Money.new(987_654_321, "USD").format(thousands_separator: " ", decimal_mark: ".")).to eq("$9 876 543.21")
      end
    end

    describe ":html option" do
      specify "(:html => true) works as documented" do
        string = Money.ca_dollar(570).format(:html => true, :with_currency => true)
        expect(string).to eq "$5.70 <span class=\"currency\">CAD</span>"
      end

      specify "should fallback to symbol if entity is not available" do
        string = Money.new(570, 'DKK').format(:html => true)
        expect(string).to eq "5,70 kr"
      end
    end

    describe ":html_wrap_symbol option" do
      specify "(:html_wrap_symbol => true) works as documented" do
        string = Money.ca_dollar(570).format(:html_wrap_symbol => true)
        expect(string).to eq "<span class=\"currency_symbol\">$</span>5.70"
      end
    end

    describe ":symbol_position option" do
      it "inserts currency symbol before the amount when set to :before" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :before)).to eq "€1.234.567,12"
      end

      it "inserts currency symbol after the amount when set to :after" do
        expect(Money.us_dollar(1_000_000_000_12).format(:symbol_position => :after)).to eq "1,000,000,000.12 $"
      end

      it "raises an ArgumentError when passed an invalid option" do
        expect{Money.euro(0).format(:symbol_position => :befor)}.to raise_error(ArgumentError)
      end
    end

    describe ":sign_before_symbol option" do
      specify "(:sign_before_symbol => true) works as documented" do
        expect(Money.us_dollar(-100000).format(:sign_before_symbol => true)).to eq "-$1,000.00"
      end

      specify "(:sign_before_symbol => false) works as documented" do
        expect(Money.us_dollar(-100000).format(:sign_before_symbol => false)).to eq "$-1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_before_symbol => nil)).to eq "$-1,000.00"
      end
    end

    describe ":symbol_before_without_space option" do
      it "does not insert space between currency symbol and amount when set to true" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :before, :symbol_before_without_space => true)).to eq "€1.234.567,12"
      end

      it "inserts space between currency symbol and amount when set to false" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :before, :symbol_before_without_space => false)).to eq "€ 1.234.567,12"
      end

      it "defaults to true" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :before)).to eq "€1.234.567,12"
      end
    end

    describe ":symbol_after_without_space option" do
      it "does not insert space between amount and currency symbol when set to true" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :after, :symbol_after_without_space => true)).to eq "1.234.567,12€"
      end

      it "inserts space between amount and currency symbol when set to false" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :after, :symbol_after_without_space => false)).to eq "1.234.567,12 €"
      end

      it "defaults to false" do
        expect(Money.euro(1_234_567_12).format(:symbol_position => :after)).to eq "1.234.567,12 €"
      end
    end

    describe ":sign_positive option" do
      specify "(:sign_positive => true, :sign_before_symbol => true) works as documented" do
        expect(Money.us_dollar(      0).format(:sign_positive => true, :sign_before_symbol => true)).to eq "$0.00"
        expect(Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => true)).to eq "+$1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => true)).to eq "-$1,000.00"
      end

      specify "(:sign_positive => true, :sign_before_symbol => false) works as documented" do
        expect(Money.us_dollar(      0).format(:sign_positive => true, :sign_before_symbol => false)).to eq "$0.00"
        expect(Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => false)).to eq "$+1,000.00"
        expect(Money.us_dollar( 100000).format(:sign_positive => true, :sign_before_symbol => nil)).to eq "$+1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => false)).to eq "$-1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => true, :sign_before_symbol => nil)).to eq "$-1,000.00"
      end

      specify "(:sign_positive => false, :sign_before_symbol => true) works as documented" do
        expect(Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => true)).to eq "$1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => true)).to eq "-$1,000.00"
      end

      specify "(:sign_positive => false, :sign_before_symbol => false) works as documented" do
        expect(Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => false)).to eq "$1,000.00"
        expect(Money.us_dollar( 100000).format(:sign_positive => false, :sign_before_symbol => nil)).to eq "$1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => false)).to eq "$-1,000.00"
        expect(Money.us_dollar(-100000).format(:sign_positive => false, :sign_before_symbol => nil)).to eq "$-1,000.00"
      end
    end

    describe ":rounded_infinite_precision option", :infinite_precision do
      it "does round fractional when set to true" do
        expect(Money.new(BigDecimal.new('12.1'), "USD").format(:rounded_infinite_precision => true)).to eq "$0.12"
        expect(Money.new(BigDecimal.new('12.5'), "USD").format(:rounded_infinite_precision => true)).to eq "$0.13"
        expect(Money.new(BigDecimal.new('123.1'), "BHD").format(:rounded_infinite_precision => true)).to eq "ب.د0.123"
        expect(Money.new(BigDecimal.new('123.5'), "BHD").format(:rounded_infinite_precision => true)).to eq "ب.د0.124"
        expect(Money.new(BigDecimal.new('100.1'), "USD").format(:rounded_infinite_precision => true)).to eq "$1.00"
        expect(Money.new(BigDecimal.new('109.5'), "USD").format(:rounded_infinite_precision => true)).to eq "$1.10"
        expect(Money.new(BigDecimal.new('1'), "MGA").format(:rounded_infinite_precision => true)).to eq "Ar0.2"
      end

      it "does not round fractional when set to false" do
        expect(Money.new(BigDecimal.new('12.1'), "USD").format(:rounded_infinite_precision => false)).to eq "$0.121"
        expect(Money.new(BigDecimal.new('12.5'), "USD").format(:rounded_infinite_precision => false)).to eq "$0.125"
        expect(Money.new(BigDecimal.new('123.1'), "BHD").format(:rounded_infinite_precision => false)).to eq "ب.د0.1231"
        expect(Money.new(BigDecimal.new('123.5'), "BHD").format(:rounded_infinite_precision => false)).to eq "ب.د0.1235"
        expect(Money.new(BigDecimal.new('100.1'), "USD").format(:rounded_infinite_precision => false)).to eq "$1.001"
        expect(Money.new(BigDecimal.new('109.5'), "USD").format(:rounded_infinite_precision => false)).to eq "$1.095"
        expect(Money.new(BigDecimal.new('1'), "MGA").format(:rounded_infinite_precision => false)).to eq "Ar0.1"
      end

      describe "with i18n = false" do
        before do
          Money.use_i18n = false
        end

        after do
          Money.use_i18n = true
        end

        it 'does round fractional when set to true' do
          expect(Money.new(BigDecimal.new('12.1'), "EUR").format(:rounded_infinite_precision => true)).to eq "€0,12"
          expect(Money.new(BigDecimal.new('12.5'), "EUR").format(:rounded_infinite_precision => true)).to eq "€0,13"
          expect(Money.new(BigDecimal.new('100.1'), "EUR").format(:rounded_infinite_precision => true)).to eq "€1,00"
          expect(Money.new(BigDecimal.new('109.5'), "EUR").format(:rounded_infinite_precision => true)).to eq "€1,10"

          expect(Money.new(BigDecimal.new('100012.1'), "EUR").format(:rounded_infinite_precision => true)).to eq "€1.000,12"
          expect(Money.new(BigDecimal.new('100012.5'), "EUR").format(:rounded_infinite_precision => true)).to eq "€1.000,13"
        end
      end

      describe "with i18n = true" do
        before do
          Money.use_i18n = true
          reset_i18n
          I18n.locale = :de
          I18n.backend.store_translations(
              :de,
              :number => { :currency => { :format => { :delimiter => ".", :separator => "," } } }
          )
        end

        after do
          reset_i18n
          I18n.locale = :en
        end

        it 'does round fractional when set to true' do
          expect(Money.new(BigDecimal.new('12.1'), "USD").format(:rounded_infinite_precision => true)).to eq "$0,12"
          expect(Money.new(BigDecimal.new('12.5'), "USD").format(:rounded_infinite_precision => true)).to eq "$0,13"
          expect(Money.new(BigDecimal.new('123.1'), "BHD").format(:rounded_infinite_precision => true)).to eq "ب.د0,123"
          expect(Money.new(BigDecimal.new('123.5'), "BHD").format(:rounded_infinite_precision => true)).to eq "ب.د0,124"
          expect(Money.new(BigDecimal.new('100.1'), "USD").format(:rounded_infinite_precision => true)).to eq "$1,00"
          expect(Money.new(BigDecimal.new('109.5'), "USD").format(:rounded_infinite_precision => true)).to eq "$1,10"
          expect(Money.new(BigDecimal.new('1'), "MGA").format(:rounded_infinite_precision => true)).to eq "Ar0,2"
        end
      end
    end

    context "when the monetary value is 0" do
      let(:money) { Money.us_dollar(0) }

      it "returns 'free' when :display_free is true" do
        expect(money.format(:display_free => true)).to eq 'free'
      end

      it "returns '$0.00' when :display_free is false or not given" do
        expect(money.format).to eq '$0.00'
        expect(money.format(:display_free => false)).to eq '$0.00'
        expect(money.format(:display_free => nil)).to eq '$0.00'
      end

      it "returns the value specified by :display_free if it's a string-like object" do
        expect(money.format(:display_free => 'gratis')).to eq 'gratis'
      end
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
      expect(Money.new(4, "BAR").format).to eq "$0.0004"
      expect(Money.new(4, "EU4").format).to eq "€0,0004"

      expect(Money.new(24, "BAR").format).to eq "$0.0024"
      expect(Money.new(24, "EU4").format).to eq "€0,0024"

      expect(Money.new(324, "BAR").format).to eq "$0.0324"
      expect(Money.new(324, "EU4").format).to eq "€0,0324"

      expect(Money.new(5324, "BAR").format).to eq "$0.5324"
      expect(Money.new(5324, "EU4").format).to eq "€0,5324"

      expect(Money.new(65324, "BAR").format).to eq "$6.5324"
      expect(Money.new(65324, "EU4").format).to eq "€6,5324"

      expect(Money.new(865324, "BAR").format).to eq "$86.5324"
      expect(Money.new(865324, "EU4").format).to eq "€86,5324"

      expect(Money.new(1865324, "BAR").format).to eq "$186.5324"
      expect(Money.new(1865324, "EU4").format).to eq "€186,5324"

      expect(Money.new(33310034, "BAR").format).to eq "$3,331.0034"
      expect(Money.new(33310034, "EU4").format).to eq "€3.331,0034"

      expect(Money.new(88833310034, "BAR").format).to eq "$8,883,331.0034"
      expect(Money.new(88833310034, "EU4").format).to eq "€8.883.331,0034"
    end

  end

  context "currencies with ambiguous signs" do

    it "returns ambiguous signs when disambiguate is not set" do
      expect(Money.new(1999_98, "USD").format).to eq("$1,999.98")
      expect(Money.new(1999_98, "CAD").format).to eq("$1,999.98")
      expect(Money.new(1999_98, "DKK").format).to eq("1.999,98 kr")
      expect(Money.new(1999_98, "NOK").format).to eq("1.999,98 kr")
      expect(Money.new(1999_98, "SEK").format).to eq("1 999,98 kr")
    end

    it "returns ambiguous signs when disambiguate is false" do
      expect(Money.new(1999_98, "USD").format(disambiguate: false)).to eq("$1,999.98")
      expect(Money.new(1999_98, "CAD").format(disambiguate: false)).to eq("$1,999.98")
      expect(Money.new(1999_98, "DKK").format(disambiguate: false)).to eq("1.999,98 kr")
      expect(Money.new(1999_98, "NOK").format(disambiguate: false)).to eq("1.999,98 kr")
      expect(Money.new(1999_98, "SEK").format(disambiguate: false)).to eq("1 999,98 kr")
    end

    it "returns disambiguate signs when disambiguate: true" do
      expect(Money.new(1999_98, "USD").format(disambiguate: true)).to eq("$1,999.98")
      expect(Money.new(1999_98, "CAD").format(disambiguate: true)).to eq("C$1,999.98")
      expect(Money.new(1999_98, "DKK").format(disambiguate: true)).to eq("1.999,98 DKK")
      expect(Money.new(1999_98, "NOK").format(disambiguate: true)).to eq("1.999,98 NOK")
      expect(Money.new(1999_98, "SEK").format(disambiguate: true)).to eq("1 999,98 SEK")
    end

    it "should never return an ambiguous format with disambiguate: true" do
      formatted_results = {}

      # When we format the same amount in all known currencies, disambiguate should return
      # all different values
      Money::Currency.all.each do |currency|
        format = Money.new(1999_98, currency).format(disambiguate: true)
        expect(formatted_results.keys).not_to include(format), "Format '#{format}' for #{currency} is ambiguous with currency #{formatted_results[format]}."
        formatted_results[format] = currency
      end
    end

    describe ":drop_trailing_zeros option" do
      specify "(:drop_trailing_zeros => true) works as documented" do
        expect(Money.new(89000, "BTC").format(:drop_trailing_zeros => true, :symbol => false)).to eq "0.00089"
        expect(Money.new(100089000, "BTC").format(:drop_trailing_zeros => true, :symbol => false)).to eq "1.00089"
        expect(Money.new(100000000, "BTC").format(:drop_trailing_zeros => true, :symbol => false)).to eq "1"
        expect(Money.new(110, "AUD").format(:drop_trailing_zeros => true, :symbol => false)).to eq "1.1"
      end

      specify "(:drop_trailing_zeros => false) works as documented" do
        expect(Money.new(89000, "BTC").format(:drop_trailing_zeros => false, :symbol => false)).to eq "0.00089000"
        expect(Money.new(100089000, "BTC").format(:drop_trailing_zeros => false, :symbol => false)).to eq "1.00089000"
        expect(Money.new(100000000, "BTC").format(:drop_trailing_zeros => false, :symbol => false)).to eq "1.00000000"
        expect(Money.new(110, "AUD").format(:drop_trailing_zeros => false, :symbol => false)).to eq "1.10"
      end
    end
  end
end
