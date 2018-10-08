# encoding: UTF-8
require 'money/money/formatting_rules'

class Money
  class Formatter
    DEFAULTS = {
      thousands_separator: '',
      decimal_mark: '.'
    }.freeze

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
    #   Money.us_dollar(0).format(display_free: true)     #=> "free"
    #   Money.us_dollar(0).format(display_free: "gratis") #=> "gratis"
    #   Money.us_dollar(0).format                            #=> "$0.00"
    #
    # @option rules [Boolean] :with_currency (false) Whether the currency name
    #  should be appended to the result string.
    #
    # @example
    #   Money.ca_dollar(100).format #=> "$1.00"
    #   Money.ca_dollar(100).format(with_currency: true) #=> "$1.00 CAD"
    #   Money.us_dollar(85).format(with_currency: true)  #=> "$0.85 USD"
    #
    # @option rules [Boolean] :rounded_infinite_precision (false) Whether the
    #  amount of money should be rounded when using {infinite_precision}
    #
    # @example
    #   Money.us_dollar(100.1).format #=> "$1.001"
    #   Money.us_dollar(100.1).format(rounded_infinite_precision: true) #=> "$1"
    #   Money.us_dollar(100.9).format(rounded_infinite_precision: true) #=> "$1.01"
    #
    # @option rules [Boolean] :no_cents (false) Whether cents should be omitted.
    #
    # @example
    #   Money.ca_dollar(100).format(no_cents: true) #=> "$1"
    #   Money.ca_dollar(599).format(no_cents: true) #=> "$5"
    #
    # @option rules [Boolean] :no_cents_if_whole (false) Whether cents should be
    #  omitted if the cent value is zero
    #
    # @example
    #   Money.ca_dollar(10000).format(no_cents_if_whole: true) #=> "$100"
    #   Money.ca_dollar(10034).format(no_cents_if_whole: true) #=> "$100.34"
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
    #   Money.new(100, "USD").format(symbol: true) #=> "$1.00"
    #   Money.new(100, "GBP").format(symbol: true) #=> "£1.00"
    #   Money.new(100, "EUR").format(symbol: true) #=> "€1.00"
    #
    #   # You can specify a false expression or an empty string to disable
    #   # prepending a money symbol.§
    #   Money.new(100, "USD").format(symbol: false) #=> "1.00"
    #   Money.new(100, "GBP").format(symbol: nil)   #=> "1.00"
    #   Money.new(100, "EUR").format(symbol: "")    #=> "1.00"
    #
    #   # If the symbol for the given currency isn't known, then it will default
    #   # to "¤" as symbol.
    #   Money.new(100, "AWG").format(symbol: true) #=> "¤1.00"
    #
    #   # You can specify a string as value to enforce using a particular symbol.
    #   Money.new(100, "AWG").format(symbol: "ƒ") #=> "ƒ1.00"
    #
    #   # You can specify a indian currency format
    #   Money.new(10000000, "INR").format(south_asian_number_formatting: true) #=> "1,00,000.00"
    #   Money.new(10000000).format(south_asian_number_formatting: true) #=> "$1,00,000.00"
    #
    # @option rules [Boolean, nil] :symbol_before_without_space (true) Whether
    #   a space between the money symbol and the amount should be inserted when
    #   +:symbol_position+ is +:before+. The default is true (meaning no space). Ignored
    #   if +:symbol+ is false or +:symbol_position+ is not +:before+.
    #
    # @example
    #   # Default is to not insert a space.
    #   Money.new(100, "USD").format #=> "$1.00"
    #
    #   # Same thing.
    #   Money.new(100, "USD").format(symbol_before_without_space: true) #=> "$1.00"
    #
    #   # If set to false, will insert a space.
    #   Money.new(100, "USD").format(symbol_before_without_space: false) #=> "$ 1.00"
    #
    # @option rules [Boolean, nil] :symbol_after_without_space (false) Whether
    #   a space between the amount and the money symbol should be inserted when
    #   +:symbol_position+ is +:after+. The default is false (meaning space). Ignored
    #   if +:symbol+ is false or +:symbol_position+ is not +:after+.
    #
    # @example
    #   # Default is to insert a space.
    #   Money.new(100, "USD").format(symbol_position: :after) #=> "1.00 $"
    #
    #   # If set to true, will not insert a space.
    #   Money.new(100, "USD").format(symbol_position: :after, symbol_after_without_space: true) #=> "1.00$"
    #
    # @option rules [Boolean, String, nil] :decimal_mark (true) Whether the
    #  currency should be separated by the specified character or '.'
    #
    # @example
    #   # If a string is specified, it's value is used.
    #   Money.new(100, "USD").format(decimal_mark: ",") #=> "$1,00"
    #
    #   # If the decimal_mark for a given currency isn't known, then it will default
    #   # to "." as decimal_mark.
    #   Money.new(100, "FOO").format #=> "$1.00"
    #
    # @option rules [Boolean, String, nil] :thousands_separator (true) Whether
    #  the currency should be delimited by the specified character or ','
    #
    # @example
    #   # If false is specified, no thousands_separator is used.
    #   Money.new(100000, "USD").format(thousands_separator: false) #=> "1000.00"
    #   Money.new(100000, "USD").format(thousands_separator: nil)   #=> "1000.00"
    #   Money.new(100000, "USD").format(thousands_separator: "")    #=> "1000.00"
    #
    #   # If a string is specified, it's value is used.
    #   Money.new(100000, "USD").format(thousands_separator: ".") #=> "$1.000.00"
    #
    #   # If the thousands_separator for a given currency isn't known, then it will
    #   # default to "," as thousands_separator.
    #   Money.new(100000, "FOO").format #=> "$1,000.00"
    #
    # @option rules [Boolean] :html (false) Whether the currency should be
    #  HTML-formatted. Only useful in combination with +:with_currency+.
    #
    # @example
    #   Money.ca_dollar(570).format(html: true, with_currency: true)
    #   #=> "$5.70 <span class=\"currency\">CAD</span>"
    #
    # @option rules [Boolean] :html_wrap (false) Whether all currency parts should be HTML-formatted.
    #
    # @example
    #   Money.ca_dollar(570).format(html_wrap: true, with_currency: true)
    #   #=> "<span class=\"money-currency-symbol\">$</span><span class=\"money-whole\">5</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">70</span> <span class=\"money-currency\">CAD</span>"
    #
    # @option rules [Boolean] :sign_before_symbol (false) Whether the sign should be
    #  before the currency symbol.
    #
    # @example
    #   # You can specify to display the sign before the symbol for negative numbers
    #   Money.new(-100, "GBP").format(sign_before_symbol: true)  #=> "-£1.00"
    #   Money.new(-100, "GBP").format(sign_before_symbol: false) #=> "£-1.00"
    #   Money.new(-100, "GBP").format                               #=> "£-1.00"
    #
    # @option rules [Boolean] :sign_positive (false) Whether positive numbers should be
    #  signed, too.
    #
    # @example
    #   # You can specify to display the sign with positive numbers
    #   Money.new(100, "GBP").format(sign_positive: true,  sign_before_symbol: true)  #=> "+£1.00"
    #   Money.new(100, "GBP").format(sign_positive: true,  sign_before_symbol: false) #=> "£+1.00"
    #   Money.new(100, "GBP").format(sign_positive: false, sign_before_symbol: true)  #=> "£1.00"
    #   Money.new(100, "GBP").format(sign_positive: false, sign_before_symbol: false) #=> "£1.00"
    #   Money.new(100, "GBP").format                               #=> "£+1.00"
    #
    # @option rules [Boolean] :disambiguate (false) Prevents the result from being ambiguous
    #  due to equal symbols for different currencies. Uses the `disambiguate_symbol`.
    #
    # @example
    #   Money.new(10000, "USD").format(disambiguate: false)   #=> "$100.00"
    #   Money.new(10000, "CAD").format(disambiguate: false)   #=> "$100.00"
    #   Money.new(10000, "USD").format(disambiguate: true)    #=> "$100.00"
    #   Money.new(10000, "CAD").format(disambiguate: true)    #=> "C$100.00"
    #
    # @option rules [Boolean] :html_wrap_symbol (false) Wraps the currency symbol
    #  in a html <span> tag.
    #
    # @example
    #   Money.new(10000, "USD").format(disambiguate: false)
    #   #=> "<span class=\"currency_symbol\">$100.00</span>
    #
    # @option rules [Symbol] :symbol_position (:before) `:before` if the currency
    #   symbol goes before the amount, `:after` if it goes after.
    #
    # @example
    #   Money.new(10000, "USD").format(symbol_position: :before) #=> "$100.00"
    #   Money.new(10000, "USD").format(symbol_position: :after)  #=> "100.00 $"
    #
    # @option rules [Boolean] :translate (true) `true` Checks for custom
    #   symbol definitions using I18n.
    #
    # @example
    #   # With the following entry in the translation files:
    #   # en:
    #   #   number:
    #   #     currency:
    #   #       symbol:
    #   #         CAD: "CAD$"
    #   Money.new(10000, "CAD").format(translate: true) #=> "CAD$100.00"
    #
    # @option rules [Boolean] :drop_trailing_zeros (false) Ignore trailing zeros after
    #   the decimal mark
    #
    # @example
    #   Money.new(89000, :btc).format(drop_trailing_zeros: true) #=> B⃦0.00089
    #   Money.new(110, :usd).format(drop_trailing_zeros: true)   #=> $1.1
    #
    # @option rules [String] :format (nil) Provide a template for formatting. `%u` will be replaced
    # with the symbol (if present) and `%n` will be replaced with the number.
    #
    # @example
    #   Money.new(10000, "USD").format(format: '%u %n') #=> "$ 100.00"
    #   Money.new(10000, "USD").format(format: '<span>%u%n</span>')  #=> "<span>$100.00</span>"
    #
    # Note that the default rules can be defined through {Money.default_formatting_rules} hash.
    #
    # @see Money.default_formatting_rules Money.default_formatting_rules for more information.
    def initialize(money, *rules)
      @money = money
      @currency = money.currency
      @rules = FormattingRules.new(@currency, *rules)
    end

    def to_s
      return free_text if show_free_text?
      result = format_number
      formatted = append_sign(result)
      append_currency_symbol(formatted)
    end

    def thousands_separator
      lookup :thousands_separator
    end

    def decimal_mark
      lookup :decimal_mark
    end

    alias_method :delimiter, :thousands_separator
    alias_method :separator, :decimal_mark

    private

    attr_reader :money, :currency, :rules

    def format_number
      whole_part, decimal_part = extract_whole_and_decimal_parts

      # Format whole and decimal parts separately
      decimal_part = format_decimal_part(decimal_part)
      whole_part = format_whole_part(whole_part)

      # Assemble the final formatted amount
      if rules[:html_wrap]
        if decimal_part.nil?
          html_wrap(whole_part, "whole")
        else
          [
            html_wrap(whole_part, "whole"),
            html_wrap(decimal_mark, "decimal-mark"),
            html_wrap(decimal_part, "decimal")
          ].join
        end
      else
        [whole_part, decimal_part].compact.join(decimal_mark)
      end
    end

    def append_sign(formatted_number)
      sign = money.negative? ? '-' : ''

      if rules[:sign_positive] == true && money.positive?
        sign = '+'
      end

      if rules[:sign_before_symbol] == true
        sign_before = sign
        sign = ''
      end

      symbol_value = symbol_value_from(rules)

      if symbol_value && !symbol_value.empty?
        if rules[:html_wrap_symbol]
          symbol_value = "<span class=\"currency_symbol\">#{symbol_value}</span>"
        elsif rules[:html_wrap]
          symbol_value = html_wrap(symbol_value, "currency-symbol")
        end

        rules[:format]
          .gsub('%u', [sign_before, symbol_value].join)
          .gsub('%n', [sign, formatted_number].join)
      else
        formatted_number = "#{sign_before}#{sign}#{formatted_number}"
      end
    end

    def append_currency_symbol(formatted_number)
      if rules[:with_currency]
        formatted_number << " "

        if rules[:html]
          formatted_number << "<span class=\"currency\">#{currency.to_s}</span>"
        elsif rules[:html_wrap]
          formatted_number << html_wrap(currency.to_s, "currency")
        else
          formatted_number << currency.to_s
        end
      end
      formatted_number
    end

    def show_free_text?
      money.zero? && rules[:display_free]
    end

    def html_wrap(string, class_name)
      "<span class=\"money-#{class_name}\">#{string}</span>"
    end

    def free_text
      rules[:display_free].respond_to?(:to_str) ? rules[:display_free] : 'free'
    end

    def format_whole_part(value)
      # Apply thousands_separator
      value.gsub regexp_format, "\\1#{thousands_separator}"
    end

    def extract_whole_and_decimal_parts
      fractional = money.fractional.abs

      # Round the infinite precision part if needed
      fractional = fractional.round if rules[:rounded_infinite_precision]

      # Translate subunits into units
      fractional_units = BigDecimal(fractional) / currency.subunit_to_unit

      # Split the result and return whole and decimal parts separately
      fractional_units.to_s('F').split('.')
    end

    def format_decimal_part(value)
      return nil if currency.decimal_places == 0 && !Money.infinite_precision
      return nil if rules[:no_cents]
      return nil if rules[:no_cents_if_whole] && value.to_i == 0

      # Pad value, making up for missing zeroes at the end
      value = value.ljust(currency.decimal_places, '0')

      # Drop trailing zeros if needed
      value.gsub!(/0*$/, '') if rules[:drop_trailing_zeros]

      value.empty? ? nil : value
    end

    def lookup(key)
      return rules[key] || DEFAULTS[key] if rules.has_key?(key)

      (Money.locale_backend && Money.locale_backend.lookup(key, currency)) || DEFAULTS[key]
    end

    def regexp_format
      if rules[:south_asian_number_formatting]
        # from http://blog.revathskumar.com/2014/11/regex-comma-seperated-indian-currency-format.html
        /(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/
      else
        /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
      end
    end

    def symbol_value_from(rules)
      if rules.has_key?(:symbol)
        if rules[:symbol] === true
          if rules[:disambiguate] && currency.disambiguate_symbol
            currency.disambiguate_symbol
          else
            money.symbol
          end
        elsif rules[:symbol]
          rules[:symbol]
        else
          ""
        end
      elsif rules[:html] || rules[:html_wrap]
        currency.html_entity == '' ? currency.symbol : currency.html_entity
      elsif rules[:disambiguate] && currency.disambiguate_symbol
        currency.disambiguate_symbol
      else
        money.symbol
      end
    end
  end
end
