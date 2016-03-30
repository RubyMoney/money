# encoding: UTF-8
class Money
  class Formatter
    extend ClassAttribute

    # @!attribute [rw] use_i18n
    #   @return [Boolean] Use this to disable i18n even if it's used by other
    #     objects in your app.
    class_attribute :use_i18n
    self.use_i18n = true

    # @!attribute default_rules
    #   @return [Hash] Use this to define a default hash of rules for every time
    #     +Money#format+ is called.  Rules provided on method call will be
    #     merged with the default ones.  To overwrite a rule, just provide the
    #     intended value while calling +format+.
    #
    #   @see +#format+ for more details.
    #
    #   @example
    #     Money.formatter.default_rules = { :display_free => true }
    #     Money.new(0, "USD").format                          # => "free"
    #     Money.new(0, "USD").format(:display_free => false)  # => "$0.00"
    class_attribute :default_rules
    self.default_rules = {}

    class << self
      def format(*args)
        new(*args).format
      end

      def decimal_str(money, decimal_places = money.currency.decimal_places)
        str = money.to_d.to_s('F')
        units, fractional = str.split('.')
        if decimal_places == 0 && fractional == '0'
          units
        else
          pad = decimal_places - fractional.size
          str << '0' * pad if pad > 0
          str
        end
      end

      # Splits string into chunks fullfilling the rightmost first:
      #
      #   rsplit_str_by('12345') # => ['12', '345']
      def rsplit_str_by(str, count)
        size = str.size
        i = size % count
        parts = i > 0 ? [str.slice(0, i)] : []
        while i < size
          parts << str.slice(i, count)
          i += count
        end
        parts
      end
    end

    attr_reader :money, :currency, :rules

    def initialize(money, **rules)
      @money = money
      @currency = money.currency
      @rules = rules
    end

    # Creates a formatted price string according to several rules.
    #
    # @param [Hash] rules The options used to format the string.
    #
    # @return [String]
    #
    # @option rules [Boolean, String] :display_free (false) Whether a zero
    #  amount of money should be formatted of "free" or as the supplied string.
    #
    # @example
    #   Money.us_dollar(0).format(:display_free => true)     #=> "free"
    #   Money.us_dollar(0).format(:display_free => "gratis") #=> "gratis"
    #   Money.us_dollar(0).format                            #=> "$0.00"
    #
    # @option rules [Boolean] :with_currency (false) Whether the currency name
    #  should be appended to the result string.
    #
    # @example
    #   Money.ca_dollar(100).format #=> "$1.00"
    #   Money.ca_dollar(100).format(:with_currency => true) #=> "$1.00 CAD"
    #   Money.us_dollar(85).format(:with_currency => true)  #=> "$0.85 USD"
    #
    # @option rules [Boolean, Integer] :round (false) Force rounding.
    #  Specify number of digits after decimal point. When true is given
    #  it uses currency's default decimal places count.
    #
    # @example
    #   Money.us_dollar(100.1).format # => "$1.001"
    #   Money.us_dollar(100.1).format(round: true) # => "$1"
    #   Money.us_dollar(100.9).format(round: true) # => "$1.01"
    #   Money.us_dollar(100.9).format(round: 1) # => "$1.00"
    #
    # @option rules [Boolean] :no_cents (false) Whether cents should be omitted.
    #
    # @example
    #   Money.ca_dollar(100).format(:no_cents => true) #=> "$1"
    #   Money.ca_dollar(599).format(:no_cents => true) #=> "$5"
    #
    # @option rules [Boolean] :no_cents_if_whole (false) Whether cents should be
    #  omitted if the cent value is zero
    #
    # @example
    #   Money.ca_dollar(10000).format(:no_cents_if_whole => true) #=> "$100"
    #   Money.ca_dollar(10034).format(:no_cents_if_whole => true) #=> "$100.34"
    #
    # @option rules [Boolean, String, nil] :symbol (true) Whether a money symbol
    #  should be prepended to the result string. The default is true. This method
    #  attempts to pick a symbol that's suitable for the given currency.
    #
    # @example
    #   Money.new(100, "USD") #=> "$1.00"
    #   Money.new(100, "GBP") #=> "£1.00"
    #   Money.new(100, "EUR") #=> "€1.00"
    #
    #   # Same thing.
    #   Money.new(100, "USD").format(:symbol => true) #=> "$1.00"
    #   Money.new(100, "GBP").format(:symbol => true) #=> "£1.00"
    #   Money.new(100, "EUR").format(:symbol => true) #=> "€1.00"
    #
    #   # You can specify a false expression or an empty string to disable
    #   # prepending a money symbol.§
    #   Money.new(100, "USD").format(:symbol => false) #=> "1.00"
    #   Money.new(100, "GBP").format(:symbol => nil)   #=> "1.00"
    #   Money.new(100, "EUR").format(:symbol => "")    #=> "1.00"
    #
    #   # If the symbol for the given currency isn't known, then it will default
    #   # to "¤" as symbol.
    #   Money.new(100, "AWG").format(:symbol => true) #=> "¤1.00"
    #
    #   # You can specify a string as value to enforce using a particular symbol.
    #   Money.new(100, "AWG").format(:symbol => "ƒ") #=> "ƒ1.00"
    #
    #   # You can specify a indian currency format
    #   Money.new(10000000, "INR").format(:south_asian => true) #=> "1,00,000.00"
    #   Money.new(10000000).format(:south_asian => true) #=> "$1,00,000.00"
    #
    # @option rules [Boolean, nil] :symbol_space (true) Whether
    #   a space between the money symbol and the amount should be inserted when
    #   +:symbol_position+ is +:before+.
    #   The default is false when +:symbol_position+ is +:before+,
    #   and true when +:symbol_position+ is +:after+.
    #   Ignored if +:symbol+ is false.
    #
    # @example
    #   # Default is to not insert a space.
    #   Money.new(100, "USD").format #=> "$1.00"
    #
    #   # Same thing.
    #   Money.new(100, "USD").format(:symbol_space => true) #=> "$1.00"
    #
    #   # If set to false, will insert a space.
    #   Money.new(100, "USD").format(:symbol_space => false) #=> "$ 1.00"
    #
    #   # Default is to insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after) #=> "1.00 $"
    #
    #   # If set to true, will not insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after, :symbol_space => true) #=> "1.00$"
    #
    # @example
    #
    # @option rules [Boolean, String, nil] :separator (true) Whether the
    #  currency should be separated by the specified character or '.'
    #
    # @example
    #   # If a string is specified, it's value is used.
    #   Money.new(100, "USD").format(:separator => ",") #=> "$1,00"
    #
    #   # If the separator for a given currency isn't known, then it will default
    #   # to "." as separator.
    #   Money.new(100, "FOO").format #=> "$1.00"
    #
    # @option rules [Boolean, String, nil] :delimiter (true) Whether
    #  the currency should be delimited by the specified character or ','
    #
    # @example
    #   # If false is specified, no delimiter is used.
    #   Money.new(100000, "USD").format(:delimiter => false) #=> "1000.00"
    #   Money.new(100000, "USD").format(:delimiter => nil)   #=> "1000.00"
    #   Money.new(100000, "USD").format(:delimiter => "")    #=> "1000.00"
    #
    #   # If a string is specified, it's value is used.
    #   Money.new(100000, "USD").format(:delimiter => ".") #=> "$1.000.00"
    #
    #   # If the delimiter for a given currency isn't known, then it will
    #   # default to "," as delimiter.
    #   Money.new(100000, "FOO").format #=> "$1,000.00"
    #
    # @option rules [Boolean] :html (false) Whether the currency should be
    #  HTML-formatted. Only useful in combination with +:with_currency+.
    #
    # @example
    #   Money.ca_dollar(570).format(:html => true, :with_currency => true)
    #   #=> "$5.70 <span class=\"currency\">CAD</span>"
    #
    # @option rules [Boolean] :sign_before_symbol (false) Whether the sign should be
    #  before the currency symbol.
    #
    # @example
    #   # You can specify to display the sign before the symbol for negative numbers
    #   Money.new(-100, "GBP").format(:sign_before_symbol => true)  #=> "-£1.00"
    #   Money.new(-100, "GBP").format(:sign_before_symbol => false) #=> "£-1.00"
    #   Money.new(-100, "GBP").format                               #=> "£-1.00"
    #
    # @option rules [Boolean] :sign_positive (false) Whether positive numbers should be
    #  signed, too.
    #
    # @example
    #   # You can specify to display the sign with positive numbers
    #   Money.new(100, "GBP").format(:sign_positive => true,  :sign_before_symbol => true)  #=> "+£1.00"
    #   Money.new(100, "GBP").format(:sign_positive => true,  :sign_before_symbol => false) #=> "£+1.00"
    #   Money.new(100, "GBP").format(:sign_positive => false, :sign_before_symbol => true)  #=> "£1.00"
    #   Money.new(100, "GBP").format(:sign_positive => false, :sign_before_symbol => false) #=> "£1.00"
    #   Money.new(100, "GBP").format                               #=> "£+1.00"
    #
    # @option rules [Boolean] :disambiguate (false) Prevents the result from being ambiguous
    #  due to equal symbols for different currencies. Uses the `disambiguate_symbol`.
    #
    # @example
    #   Money.new(10000, "USD").format(:disambiguate => false)   #=> "$100.00"
    #   Money.new(10000, "CAD").format(:disambiguate => false)   #=> "$100.00"
    #   Money.new(10000, "USD").format(:disambiguate => true)    #=> "$100.00"
    #   Money.new(10000, "CAD").format(:disambiguate => true)    #=> "C$100.00"
    #
    # @option rules [Boolean] :html_wrap_symbol (false) Wraps the currency symbol
    #  in a html <span> tag.
    #
    # @example
    #   Money.new(10000, "USD").format(:disambiguate => false)
    #   #=> "<span class=\"currency_symbol\">$100.00</span>
    #
    # @option rules [Symbol] :symbol_position (:before) `:before` if the currency
    #   symbol goes before the amount, `:after` if it goes after.
    #
    # @example
    #   Money.new(10000, "USD").format(:symbol_position => :before) #=> "$100.00"
    #   Money.new(10000, "USD").format(:symbol_position => :after)  #=> "100.00 $"
    #
    # @option rules [Boolean] :translate_symbol (true) `true` Checks for custom
    #   symbol definitions using I18n.
    #
    # @example
    #   # With the following entry in the translation files:
    #   # en:
    #   #   number:
    #   #     currency:
    #   #       symbol:
    #   #         CAD: "CAD$"
    #   Money.new(10000, "CAD").format(:translate_symbol => true) #=> "CAD$100.00"
    #
    # @example
    #   Money.new(89000, :btc).format(:drop_trailing_zeros => true) #=> B⃦0.00089
    #   Money.new(110, :usd).format(:drop_trailing_zeros => true)   #=> $1.1
    #
    # Note that the default rules can be defined through {Money.default_rules} hash.
    #
    # @see Money.default_rules Money.default_rules for more information.
    def format
      prepare_rules
      return display_free if money.to_d == 0 && rules[:display_free]
      str = format_number(money.to_d)
      str = add_symbol_and_sign(str)
      add_currency(str)
    end

    def format_number(val)
      number_str =
        if rules[:no_cents] || (rules[:no_cents_if_whole] && val % 1 == 0)
          val.to_i.to_s
        else
          round = rules[:round]
          if round
            decimal_places = round == true ? currency.decimal_places : round
            val = val.round(decimal_places)
          end
          self.class.decimal_str(val.abs, decimal_places || currency.decimal_places)
        end

      units, fractions = number_str.split('.')
      if rules[:drop_trailing_zeros]
        fractions.sub!(/0+\z/, '')
        fractions = nil if fractions.empty?
      end

      units = apply_delimiter(units)
      separator = rules[:separator] || self.separator
      fractions ? "#{units}#{separator}#{fractions}" : units
    end

    def add_symbol_and_sign(number_str)
      symbol_position = self.symbol_position
      symbol = self.symbol
      sign =
        if money.negative?
          '-'
        elsif rules[:sign_positive] && money.positive?
          '+'
        end

      if rules[:sign_before_symbol]
        sign_before = sign
        sign = nil
      end

      if symbol && !symbol.empty?
        symbol = "<span class=\"currency_symbol\">#{symbol}</span>" if rules[:html_wrap_symbol]
        case symbol_position
        when :before
          symbol_space = rules[:symbol_space] ? ' ' : nil
          "#{sign_before}#{symbol}#{symbol_space}#{sign}#{number_str}"
        when :after
          symbol_space = rules.fetch(:symbol_space) { true } ? ' ' : nil
          "#{sign_before}#{sign}#{number_str}#{symbol_space}#{symbol}"
        else
          raise ArgumentError, ':symbol_position must be :before or :after'
        end
      else
        "#{sign_before}#{sign}#{number_str}"
      end
    end

    def add_currency(str)
      return str unless rules[:with_currency]
      currency_str = currency.to_s
      currency_str = "<span class=\"currency\">#{currency_str}</span>" if rules[:html]
      str << ' ' << currency_str
    end

    def display_free
      rules[:display_free].respond_to?(:to_str) ? rules[:display_free] : 'free'
    end

    def delimiter
      val_from_i18n(:delimiter, ',')
    end

    def separator
      val_from_i18n(:separator, '.')
    end

    def symbol
      if rules[:translate_symbol] && rules[:symbol] != false
        val = symbol_from_i18n
        return val if val
      end
      if rules.key?(:symbol)
        symbol = rules[:symbol]
        symbol == true ? money.symbol : symbol
      elsif rules[:html]
        currency.html_entity || currency.symbol
      else
        rules[:disambiguate] && currency.disambiguate_symbol || money.symbol
      end
    end

    def symbol_position
      rules[:symbol_position] || (currency.symbol_first? ? :before : :after)
    end

    private

    def val_from_i18n(name, default)
      if self.class.use_i18n
        I18n.t name, scope:  'number.currency.format', default: ->(*) do
          I18n.t name, scope: 'number.format',
            default: ->(*) { currency.public_send(name) || default }
        end
      else
        currency.public_send(name) || default
      end
    end

    def symbol_from_i18n
      I18n.t currency.code, scope: 'number.currency.symbol', raise: true
    rescue I18n::MissingTranslationData
    end

    def apply_delimiter(units)
      parts =
        if rules[:south_asian]
          self.class.rsplit_str_by(units[0...-3], 2) + [[units[-3..-1]]]
        else
          self.class.rsplit_str_by(units, 3)
        end
      return parts.first if parts.one?
      delimiter = rules.key?(:delimiter) ? rules[:delimiter] || '' : self.delimiter
      parts.join(delimiter)
    end

    def prepare_rules
      @rules = self.class.default_rules.merge(rules)
    end
  end
end
