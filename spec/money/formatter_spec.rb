# encoding: utf-8

describe Money::Formatter do
  subject { Money.formatter.new(money, rules) }
  let(:money) { Money.empty('USD') }
  let(:rules) { {} }

  let(:bar_attrs) do
    {
      priority: 1,
      code: 'BAR',
      iso_numeric: '840',
      name: 'Dollar with 4 decimal places',
      symbol: '$',
      subunit: 'Cent',
      subunit_to_unit: 10000,
      symbol_first: true,
      html_entity: '$',
      decimal_mark: '.',
      thousands_separator: ',',
      smallest_denomination: 1,
    }
  end
  let(:indian_bar_attrs) do
    {
      priority: 1,
      code: 'INDIAN_BAR',
      iso_numeric: '840',
      name: 'Dollar with 4 decimal places',
      symbol: '$',
      subunit: 'Cent',
      subunit_to_unit: 10000,
      symbol_first: true,
      html_entity: '$',
      decimal_mark: '.',
      thousands_separator: ',',
      south_asian: true,
      smallest_denomination: 1,
    }
  end
  let(:eu4_attrs) do
    {
      priority: 1,
      code: 'EU4',
      iso_numeric: '841',
      name: 'Euro with 4 decimal places',
      symbol: '€',
      subunit: 'Cent',
      subunit_to_unit: 10000,
      symbol_first: true,
      html_entity: '€',
      decimal_mark: ',',
      thousands_separator: '.',
      smallest_denomination: 1,
    }
  end

  describe '#rsplit_str_by' do
    subject { ->(*args) { described_class.rsplit_str_by(*args) } }
    it 'splits string' do
      expect(subject.call '12', 3).to eq %w(12)
      expect(subject.call '1234', 2).to eq %w(12 34)
      expect(subject.call '1234', 3).to eq %w(1 234)
      expect(subject.call '1234567890', 3).to eq %w(1 234 567 890)
    end
  end

  context 'without i18n' do
    its(:delimiter) { should eq ',' }
    its(:separator) { should eq '.' }
  end

  context 'with i18n' do
    context 'with number.format.*' do
      with_locale :de, number: {format: {delimiter: '.', separator: ','}}
      its(:delimiter) { should eq '.' }
      its(:separator) { should eq ',' }

      context 'but use_i18n = false' do
        use_i18n false
        its(:delimiter) { should eq ',' }
        its(:separator) { should eq '.' }
      end
    end

    context 'with number.currency.format.*' do
      with_locale :de, number: {currency: {format: {delimiter: '.', separator: ','}}}
      its(:delimiter) { should eq '.' }
      its(:separator) { should eq ',' }
    end

    context 'with number.currency.symbol.*' do
      with_locale :de, number: {currency: {symbol: {CAD: 'CAD$'}}}
      let(:money) { Money.empty('CAD') }

      it 'should use CAD$ as the currency symbol' do
        expect(money.format(translate_symbol: true)).to eq('CAD$0.00')
      end
    end

    context 'with overridden i18n settings' do
      it 'should respect explicit overriding of delimiter when separator ' \
        'collide and there’s no decimal component for currencies that have no subunit' do
        expect(Money.new(300_000, 'ISK').format(delimiter: '.', separator: ',')).to eq 'kr300.000'
      end

      it 'should respect explicit overriding of delimiter when separator ' \
        'collide and there’s no decimal component for currencies with ' \
        'subunits that drop_trailing_zeros' do
        expect(
          Money.usd(3_000).format(delimiter: '.', separator: ',', drop_trailing_zeros: true)
        ).to eq '$3.000'
      end
    end
  end

  describe "#format" do
    it "returns the monetary value as a string" do
      expect(Money.cad(1).format).to eq '$1.00'
      expect(Money.usd(400.08).format).to eq '$400.08'
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(1, 'BHD').format).to eq 'ب.د1.000'
    end

    it "does not display a decimal when :subunit_to_unit is 1" do
      expect(Money.new(1_000, 'VUV').format).to eq 'Vt1,000'
    end

    it "respects the delimiter and separator defaults" do
      one_thousand = Proc.new do |currency|
        Money.new(1000, currency).format
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
      expect(one_thousand["JPY"]).to eq "¥1,000"
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
      expect(one_thousand["GHS"]).to eq "₵1,000.00"
    end

    it "inserts commas into the result if the amount is sufficiently large" do
      expect(Money.usd(1_000_000_000.12).format).to eq '$1,000,000,000.12'
      expect(Money.usd(1_000_000_000.12).format(no_cents: true)).to eq '$1,000,000,000'
    end

    it "inserts thousands separator into the result if the amount is sufficiently large " \
      "and the currency symbol is at the end" do
      expect(Money.eur(1_234_567.12).format).to eq '€1.234.567,12'
      expect(Money.eur(1_234_567.12).format(no_cents: true)).to eq '€1.234.567'
    end

    context 'when default_rules defines (display_free: true)' do
      around do |ex|
        begin
          described_class.default_rules = {display_free: "you won't pay a thing"}
          ex.run
        ensure
          described_class.default_rules = {}
        end
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

    context 'when default_rules is not defined' do
      context 'acknowledges provided rule' do
        it 'acknowledges provided rule' do
          expect(Money.usd(1).format(with_currency: true)).to eq '$1.00 USD'
        end
      end
    end

    describe ':with_currency option' do
      specify '(:with_currency option => true) works as documented' do
        expect(Money.cad(1.00).format(with_currency: true)).to eq '$1.00 CAD'
        expect(Money.usd(0.85).format(with_currency: true)).to eq '$0.85 USD'
      end
    end

    describe ':no_cents option' do
      specify '(:with_currency option => true) works as documented' do
        expect(Money.cad(1.00).format(no_cents: true)).to eq '$1'
        expect(Money.cad(5.99).format(no_cents: true)).to eq '$5'
        expect(Money.cad(5.70).format(no_cents: true, with_currency: true)).to eq '$5 CAD'
        expect(Money.cad(390).format(no_cents: true)).to eq '$390'
      end

      it "respects :subunit_to_unit currency property" do
        expect(Money.new(1, 'BHD').format(no_cents: true)).to eq 'ب.د1'
      end

      it 'inserts thousand separators if symbol contains decimal mark and no_cents is true' do
        expect(Money.new(1_000_000, 'AMD').format(no_cents: true)).to eq '1,000,000 դր.'
        expect(Money.new(1_000_000, 'USD').format(no_cents: true)).to eq '$1,000,000'
        expect(Money.new(1_000_000, 'RUB').format(no_cents: true)).to eq '1.000.000 ₽'
      end

      it "doesn't incorrectly format HTML" do
        expect(Money.new(19.99, 'RUB').format(html: true, no_cents: true)).to eq '19 &#x20BD;'
      end
    end

    context 'with (:no_cents_if_whole => true)' do
      subject { ->(money) { money.format(no_cents_if_whole: true, symbol: false) } }
      it 'works as documented' do
        expect(subject.call(Money.new(   10000, 'VUV'))).to eq '10,000'
        expect(subject.call(Money.new(   10034, 'VUV'))).to eq '10,034'
        expect(subject.call(Money.new(   10000, 'MGA'))).to eq '10,000'
        expect(subject.call(Money.new(  1003.4, 'MGA'))).to eq '1,003.4'
        expect(subject.call(Money.new(   10000, 'VND'))).to eq '10.000'
        expect(subject.call(Money.new(   10034, 'VND'))).to eq '10.034'
        expect(subject.call(Money.new(     100, 'USD'))).to eq '100'
        expect(subject.call(Money.new(  100.34, 'USD'))).to eq '100.34'
        expect(subject.call(Money.new(      10, 'IQD'))).to eq '10'
        expect(subject.call(Money.new(  10.034, 'IQD'))).to eq '10.034'
      end
    end

    context 'with (:no_cents_if_whole => false)' do
      subject { ->(money) { money.format(no_cents_if_whole: false, symbol: false) } }
      it 'works as documented' do
        expect(subject.call(Money.new(   10000, 'VUV'))).to eq '10,000'
        expect(subject.call(Money.new(   10034, 'VUV'))).to eq '10,034'
        expect(subject.call(Money.new(    1000, 'MGA'))).to eq '1,000.0'
        expect(subject.call(Money.new(  1003.4, 'MGA'))).to eq '1,003.4'
        expect(subject.call(Money.new(   10000, 'VND'))).to eq '10.000'
        expect(subject.call(Money.new(   10034, 'VND'))).to eq '10.034'
        expect(subject.call(Money.new(     100, 'USD'))).to eq '100.00'
        expect(subject.call(Money.new(  100.34, 'USD'))).to eq '100.34'
        expect(subject.call(Money.new(      10, 'IQD'))).to eq '10.000'
        expect(subject.call(Money.new(  10.034, 'IQD'))).to eq '10.034'
      end
    end

    describe ':symbol option' do
      specify '(:symbol => a symbol string) uses the given value as the money symbol' do
        expect(Money.new(1, 'GBP').format(symbol: '£')).to eq '£1.00'
      end

      specify "(:symbol => true) returns symbol based on the given currency code" do
        one = Proc.new do |currency|
          Money.new(1, currency).format(symbol: true)
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
        expect(one["JPY"]).to eq "¥1"
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
        expect(one["GHS"]).to eq "₵1.00"
      end

      specify "(:symbol => true) returns $ when currency code is not recognized" do
        currency = Money::Currency.new("EUR")
        expect(currency).to receive(:symbol).and_return(nil)
        expect(Money.new(1, currency).format(symbol: true)).to eq '¤1,00'
      end

      specify "(:symbol => some non-Boolean value that evaluates to true) returns " \
        "symbol based on the given currency code" do
        expect(Money.new(1, 'GBP').format(symbol: true)).to eq '£1.00'
        expect(Money.new(1, 'EUR').format(symbol: true)).to eq '€1,00'
        expect(Money.new(1, 'SEK').format(symbol: true)).to eq '1,00 kr'
      end

      specify "(:symbol => "", nil or false) returns the amount without a symbol" do
        money = Money.new(1, "GBP")
        expect(money.format(:symbol => "")).to eq "1.00"
        expect(money.format(:symbol => nil)).to eq "1.00"
        expect(money.format(:symbol => false)).to eq "1.00"

        money = Money.new(100, "JPY")
        expect(money.format(:symbol => false)).to eq "100"
      end

      it 'defaults :symbol to true' do
        expect(Money.usd(1).format).to eq '$1.00'
        expect(Money.gbp(1).format).to eq '£1.00'
        expect(Money.eur(1).format).to eq '€1,00'
      end

      specify '(:symbol => false) returns a signed amount without a symbol' do
        expect(Money.eur(-1).format(symbol: false)).to eq '-1,00'
        expect(Money.eur(1).format(symbol: false, sign_positive: true)).to eq '+1,00'
      end
    end

    describe ':separator option' do
      specify '(:separator => a separator string) works as documented' do
        expect(Money.usd(1).format(separator: ',')).to eq '$1,00'
      end

      it "defaults to '.' if currency isn't recognized" do
        expect(Money.new(1, 'ZWD').format).to eq '$1.00'
      end
    end

    describe ':south_asian delimiter' do
      around { |ex| with_currency(indian_bar_attrs) { ex.run } }

      specify '(:south_asian => true) works as documented' do
        expect(Money.new(100000, 'INR').format(south_asian: true, symbol: false)).
          to eq '1,00,000.00'
        expect(Money.new(100000, 'INDIAN_BAR').format(south_asian: true, symbol: false)).
          to eq '1,00,000.0000'
        expect(Money.usd(100000).format(south_asian: true)).to eq '$1,00,000.00'
      end
    end

    describe ':delimiter option' do
      specify '(:delimiter => a delimiter string) works as documented' do
        expect(Money.usd(1000).format(delimiter: '.')).to eq '$1.000.00'
        expect(Money.usd(2000).format(delimiter: '')).to eq '$2000.00'
      end

      specify '(:delimiter => false or nil) works as documented' do
        expect(Money.usd(1000).format(delimiter: false)).to eq '$1000.00'
        expect(Money.usd(2000).format(delimiter: nil)).to eq '$2000.00'
      end

      specify '(:delimiter => a delimiter string) works as documented' do
        expect(Money.usd(1000).format(delimiter: '.')).to eq '$1.000.00'
        expect(Money.usd(2000).format(delimiter: '')).to eq '$2000.00'
      end

      specify '(:delimiter => false or nil) works as documented' do
        expect(Money.usd(1000).format(delimiter: false)).to eq '$1000.00'
        expect(Money.usd(2000).format(delimiter: nil)).to eq '$2000.00'
      end

      it "defaults to ',' if currency isn't recognized" do
        expect(Money.new(1000, 'ZWD').format).to eq '$1,000.00'
      end

      context "without i18n" do
        use_i18n false

        it 'should respect explicit overriding of delimiter when separator collide and ' \
          'there’s no decimal component for currencies that have no subunit' do
          expect(Money.new(300_000, 'ISK').format(delimiter: ',', separator: '.')).to eq 'kr300,000'
        end

        it 'should respect explicit overriding of delimiter when separator collide and ' \
          'there’s no decimal component for currencies with subunits that drop_trailing_zeros' do
          expect(
            Money.new(3000, 'USD').
              format(delimiter: '.', separator: ',', drop_trailing_zeros: true)
          ).to eq '$3.000'
        end
      end
    end

    describe ':delimiter and :separator option' do
      specify '(:delimiter => a delimiter string, :separator => a separator string) works as documented' do
        expect(Money.usd(123_456_7.89).format(delimiter: '.', separator: ',')).
          to eq('$1.234.567,89')
        expect(Money.usd(987_654_3.21).format(delimiter: ' ', separator: '.')).
          to eq('$9 876 543.21')
      end
    end

    describe ':html option' do
      specify '(:html => true) works as documented' do
        expect(Money.cad(5.7).format(html: true, with_currency: true)).
          to eq '$5.70 <span class="currency">CAD</span>'
      end

      specify 'should fallback to symbol if entity is not available' do
        expect(Money.new(5.7, 'DKK').format(html: true)).to eq "5,70 kr."
      end
    end

    describe ':html_wrap_symbol option' do
      specify '(:html_wrap_symbol => true) works as documented' do
        expect(Money.cad(5.7).format(html_wrap_symbol: true)).
          to eq '<span class="currency_symbol">$</span>5.70'
      end
    end

    describe ':symbol_position option' do
      it 'inserts currency symbol before the amount when set to :before' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :before)).
          to eq '€1.234.567,12'
      end

      it 'inserts currency symbol after the amount when set to :after' do
        expect(Money.usd(1_000_000_000.12).format(symbol_position: :after)).
          to eq '1,000,000,000.12 $'
      end

      it 'raises an ArgumentError when passed an invalid option' do
        expect { Money.eur(0).format(symbol_position: :befor) }.to raise_error(ArgumentError)
      end
    end

    describe ':sign_before_symbol option' do
      specify '(:sign_before_symbol => true) works as documented' do
        expect(Money.usd(-1000).format(sign_before_symbol: true)).to eq '-$1,000.00'
      end

      specify '(:sign_before_symbol => false) works as documented' do
        expect(Money.usd(-1000).format(sign_before_symbol: false)).to eq '$-1,000.00'
        expect(Money.usd(-1000).format(sign_before_symbol: nil)).to eq '$-1,000.00'
      end
    end

    describe ':symbol_space option' do
      it 'does not insert space between currency symbol and amount when set to false' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :before, symbol_space: false)).
          to eq '€1.234.567,12'
      end

      it 'inserts space between currency symbol and amount when set to true' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :before, symbol_space: true)).
          to eq '€ 1.234.567,12'
      end

      it 'defaults to false' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :before)).to eq '€1.234.567,12'
      end
    end

    describe ':symbol_space option' do
      it 'does not insert space between amount and currency symbol when set to false' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :after, symbol_space: false)).
          to eq '1.234.567,12€'
      end

      it 'inserts space between amount and currency symbol when set to true' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :after, symbol_space: true)).
          to eq '1.234.567,12 €'
      end

      it 'defaults to true' do
        expect(Money.eur(1_234_567.12).format(symbol_position: :after)).to eq '1.234.567,12 €'
      end
    end

    describe ':sign_positive option' do
      subject do
        ->(money, sign_positive, sign_before_symbol) do
          money.format(sign_positive: sign_positive, sign_before_symbol: sign_before_symbol)
        end
      end

      specify '(:sign_positive => true, :sign_before_symbol => true) works as documented' do
        expect(subject.call(Money.usd(      0), true, true)).to eq '$0.00'
        expect(subject.call(Money.usd( 1000), true, true)).to eq '+$1,000.00'
        expect(subject.call(Money.usd(-1000), true, true)).to eq '-$1,000.00'
      end

      specify '(:sign_positive => true, :sign_before_symbol => false) works as documented' do
        expect(subject.call(Money.usd(      0), true, false)).to eq '$0.00'
        expect(subject.call(Money.usd( 1000), true, false)).to eq '$+1,000.00'
        expect(subject.call(Money.usd( 1000), true, nil)).to eq '$+1,000.00'
        expect(subject.call(Money.usd(-1000), true, false)).to eq '$-1,000.00'
        expect(subject.call(Money.usd(-1000), true, nil)).to eq '$-1,000.00'
      end

      specify '(:sign_positive => false, :sign_before_symbol => true) works as documented' do
        expect(subject.call(Money.usd( 1000), false, true)).to eq '$1,000.00'
        expect(subject.call(Money.usd(-1000), false, true)).to eq '-$1,000.00'
      end

      specify '(:sign_positive => false, :sign_before_symbol => false) works as documented' do
        expect(subject.call(Money.usd( 1000), false, false)).to eq '$1,000.00'
        expect(subject.call(Money.usd( 1000), false, nil)).to eq '$1,000.00'
        expect(subject.call(Money.usd(-1000), false, false)).to eq '$-1,000.00'
        expect(subject.call(Money.usd(-1000), false, nil)).to eq '$-1,000.00'
      end
    end

    describe ':round option', :infinite_precision do
      it 'does round fractional when set to true' do
        expect(Money.new(  0.121, 'USD').format(round: true)).to eq '$0.12'
        expect(Money.new(  0.125, 'USD').format(round: true)).to eq '$0.13'
        expect(Money.new( 0.1231, 'BHD').format(round: true)).to eq 'ب.د0.123'
        expect(Money.new( 0.1235, 'BHD').format(round: true)).to eq 'ب.د0.124'
        expect(Money.new(  1.001, 'USD').format(round: true)).to eq '$1.00'
        expect(Money.new(  1.095, 'USD').format(round: true)).to eq '$1.10'
        expect(Money.new(    0.2, 'MGA').format(round: true)).to eq 'Ar0.2'
      end

      it 'does not round fractional when set to false' do
        expect(Money.new(  0.121, 'USD').format(round: false)).to eq '$0.121'
        expect(Money.new(  0.125, 'USD').format(round: false)).to eq '$0.125'
        expect(Money.new( 0.1231, 'BHD').format(round: false)).to eq 'ب.د0.1231'
        expect(Money.new( 0.1235, 'BHD').format(round: false)).to eq 'ب.د0.1235'
        expect(Money.new(  1.001, 'USD').format(round: false)).to eq '$1.001'
        expect(Money.new(  1.095, 'USD').format(round: false)).to eq '$1.095'
        expect(Money.new(    0.2, 'MGA').format(round: false)).to eq 'Ar0.2'
      end

      describe 'with i18n = false' do
        use_i18n false

        it 'does round fractional when set to true' do
          expect(Money.new( 0.121, 'EUR').format(round: true)).to eq '€0,12'
          expect(Money.new( 0.125, 'EUR').format(round: true)).to eq '€0,13'
          expect(Money.new( 1.001, 'EUR').format(round: true)).to eq '€1,00'
          expect(Money.new( 1.095, 'EUR').format(round: true)).to eq '€1,10'
          expect(Money.new(1000.121, 'EUR').format(round: true)).to eq '€1.000,12'
          expect(Money.new(1000.125, 'EUR').format(round: true)).to eq '€1.000,13'
        end
      end

      describe 'with i18n = true' do
        with_locale :de, number: {currency: {format: {delimiter: '.', separator: ','}}}

        it 'does round fractional when set to true' do
          expect(Money.new( 0.121, 'USD').format(round: true)).to eq '$0,12'
          expect(Money.new( 0.125, 'USD').format(round: true)).to eq '$0,13'
          expect(Money.new(0.1231, 'BHD').format(round: true)).to eq 'ب.د0,123'
          expect(Money.new(0.1235, 'BHD').format(round: true)).to eq 'ب.د0,124'
          expect(Money.new( 1.001, 'USD').format(round: true)).to eq '$1,00'
          expect(Money.new( 1.095, 'USD').format(round: true)).to eq '$1,10'
          expect(Money.new(   0.2, 'MGA').format(round: true)).to eq 'Ar0,2'
        end
      end
    end

    context "when the monetary value is 0" do
      let(:money) { Money.usd(0) }

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

  context 'custom currencies with 4 decimal places' do
    around { |ex| with_currency(bar_attrs) { ex.run } }
    around { |ex| with_currency(eu4_attrs) { ex.run } }

    it 'respects custom subunit to unit, decimal and thousands separator' do
      expect(Money.new(0.0004, 'BAR').format).to eq '$0.0004'
      expect(Money.new(0.0004, 'EU4').format).to eq '€0,0004'

      expect(Money.new(0.0024, 'BAR').format).to eq '$0.0024'
      expect(Money.new(0.0024, 'EU4').format).to eq '€0,0024'

      expect(Money.new(0.0324, 'BAR').format).to eq '$0.0324'
      expect(Money.new(0.0324, 'EU4').format).to eq '€0,0324'

      expect(Money.new(0.5324, 'BAR').format).to eq '$0.5324'
      expect(Money.new(0.5324, 'EU4').format).to eq '€0,5324'

      expect(Money.new(6.5324, 'BAR').format).to eq '$6.5324'
      expect(Money.new(6.5324, 'EU4').format).to eq '€6,5324'

      expect(Money.new(86.5324, 'BAR').format).to eq '$86.5324'
      expect(Money.new(86.5324, 'EU4').format).to eq '€86,5324'

      expect(Money.new(186.5324, 'BAR').format).to eq '$186.5324'
      expect(Money.new(186.5324, 'EU4').format).to eq '€186,5324'

      expect(Money.new(3331.0034, 'BAR').format).to eq '$3,331.0034'
      expect(Money.new(3331.0034, 'EU4').format).to eq '€3.331,0034'

      expect(Money.new(8883331.0034, 'BAR').format).to eq '$8,883,331.0034'
      expect(Money.new(8883331.0034, 'EU4').format).to eq '€8.883.331,0034'
    end
  end

  context 'currencies with ambiguous signs' do
    it 'returns ambiguous signs when disambiguate is not set' do
      expect(Money.new(1999.98, 'USD').format).to eq('$1,999.98')
      expect(Money.new(1999.98, 'CAD').format).to eq('$1,999.98')
      expect(Money.new(1999.98, 'DKK').format).to eq('1.999,98 kr.')
      expect(Money.new(1999.98, 'NOK').format).to eq('1.999,98 kr')
      expect(Money.new(1999.98, 'SEK').format).to eq('1 999,98 kr')
    end

    it 'returns ambiguous signs when disambiguate is false' do
      expect(Money.new(1999.98, 'USD').format(disambiguate: false)).to eq('$1,999.98')
      expect(Money.new(1999.98, 'CAD').format(disambiguate: false)).to eq('$1,999.98')
      expect(Money.new(1999.98, 'DKK').format(disambiguate: false)).to eq('1.999,98 kr.')
      expect(Money.new(1999.98, 'NOK').format(disambiguate: false)).to eq('1.999,98 kr')
      expect(Money.new(1999.98, 'SEK').format(disambiguate: false)).to eq('1 999,98 kr')
    end

    it 'returns disambiguate signs when disambiguate: true' do
      expect(Money.new(1999.98, 'USD').format(disambiguate: true)).to eq('US$1,999.98')
      expect(Money.new(1999.98, 'CAD').format(disambiguate: true)).to eq('C$1,999.98')
      expect(Money.new(1999.98, 'DKK').format(disambiguate: true)).to eq('1.999,98 DKK')
      expect(Money.new(1999.98, 'NOK').format(disambiguate: true)).to eq('1.999,98 NOK')
      expect(Money.new(1999.98, 'SEK').format(disambiguate: true)).to eq('1 999,98 SEK')
    end

    it 'returns disambiguate signs when disambiguate: true and symbol: true' do
      expect(Money.new(1999.98, 'USD').format(disambiguate: true, symbol: true)).to eq('US$1,999.98')
      expect(Money.new(1999.98, 'CAD').format(disambiguate: true, symbol: true)).to eq('C$1,999.98')
      expect(Money.new(1999.98, 'DKK').format(disambiguate: true, symbol: true)).to eq('1.999,98 DKK')
      expect(Money.new(1999.98, 'NOK').format(disambiguate: true, symbol: true)).to eq('1.999,98 NOK')
      expect(Money.new(1999.98, 'SEK').format(disambiguate: true, symbol: true)).to eq('1 999,98 SEK')
    end

    it 'returns no signs when disambiguate: true and symbol: false' do
      expect(Money.new(1999.98, 'USD').format(disambiguate: true, symbol: false)).to eq('1,999.98')
      expect(Money.new(1999.98, 'CAD').format(disambiguate: true, symbol: false)).to eq('1,999.98')
      expect(Money.new(1999.98, 'DKK').format(disambiguate: true, symbol: false)).to eq('1.999,98')
      expect(Money.new(1999.98, 'NOK').format(disambiguate: true, symbol: false)).to eq('1.999,98')
      expect(Money.new(1999.98, 'SEK').format(disambiguate: true, symbol: false)).to eq('1 999,98')
    end

    it "should never return an ambiguous format with disambiguate: true" do
      formatted_results = {}

      # When we format the same amount in all known currencies, disambiguate should return
      # all different values
      Money::Currency.all.each do |currency|
        format = Money.new(1999_98, currency).format(disambiguate: true)
        expect(formatted_results.keys).not_to include(format),
          "Format '#{format}' for #{currency} is ambiguous with currency #{formatted_results[format]}."
        formatted_results[format] = currency
      end
    end

    context '(:drop_trailing_zeros => true)' do
      subject { ->(money, val) { money.format(drop_trailing_zeros: val, symbol: false) } }
      it 'works as documented' do
        expect(subject.call(Money.new(0.00089, 'BTC'), true)).to eq '0.00089'
        expect(subject.call(Money.new(1.00089, 'BTC'), true)).to eq '1.00089'
        expect(subject.call(Money.new(1,       'BTC'), true)).to eq '1'
        expect(subject.call(Money.new(1.1,     'AUD'), true)).to eq '1.1'
      end
    end

    context '(:drop_trailing_zeros => false)' do
      subject { ->(money, val) { money.format(drop_trailing_zeros: val, symbol: false) } }
      it 'works as documented' do
        expect(subject.call(Money.new(0.00089,  'BTC'), false)).to eq '0.00089000'
        expect(subject.call(Money.new(1.00089,  'BTC'), false)).to eq '1.00089000'
        expect(subject.call(Money.new(1,        'BTC'), false)).to eq '1.00000000'
        expect(subject.call(Money.new(1.1,      'AUD'), false)).to eq '1.10'
      end
    end
  end
end
