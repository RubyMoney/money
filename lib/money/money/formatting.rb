# encoding: UTF-8
class Money
  module Formatting
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
    # @option rules [Boolean] :rounded_infinite_precision (false) Whether the
    #  amount of money should be rounded when using {infinite_precision}
    #
    # @example
    #   Money.us_dollar(100.1).format #=> "$1.001"
    #   Money.us_dollar(100.1).format(:rounded_infinite_precision => true) #=> "$1"
    #   Money.us_dollar(100.9).format(:rounded_infinite_precision => true) #=> "$1.01"
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
    #   Money.new(10000000, "INR").format(:south_asian_number_formatting => true) #=> "1,00,000.00"
    #   Money.new(10000000).format(:south_asian_number_formatting => true) #=> "$1,00,000.00"
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
    #   Money.new(100, "USD").format(:symbol_before_without_space => true) #=> "$1.00"
    #
    #   # If set to false, will insert a space.
    #   Money.new(100, "USD").format(:symbol_before_without_space => false) #=> "$ 1.00"
    #
    # @option rules [Boolean, nil] :symbol_after_without_space (false) Whether
    #   a space between the amount and the money symbol should be inserted when
    #   +:symbol_position+ is +:after+. The default is false (meaning space). Ignored
    #   if +:symbol+ is false or +:symbol_position+ is not +:after+.
    #
    # @example
    #   # Default is to insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after) #=> "1.00 $"
    #
    #   # If set to true, will not insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after, :symbol_after_without_space => true) #=> "1.00$"
    #
    # @option rules [Boolean, String, nil] :decimal_mark (true) Whether the
    #  currency should be separated by the specified character or '.'
    #
    # @example
    #   # If a string is specified, it's value is used.
    #   Money.new(100, "USD").format(:decimal_mark => ",") #=> "$1,00"
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
    #   Money.new(100000, "USD").format(:thousands_separator => false) #=> "1000.00"
    #   Money.new(100000, "USD").format(:thousands_separator => nil)   #=> "1000.00"
    #   Money.new(100000, "USD").format(:thousands_separator => "")    #=> "1000.00"
    #
    #   # If a string is specified, it's value is used.
    #   Money.new(100000, "USD").format(:thousands_separator => ".") #=> "$1.000.00"
    #
    #   # If the thousands_separator for a given currency isn't known, then it will
    #   # default to "," as thousands_separator.
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
    #   Money.new(10000, "CAD").format(:translate => true) #=> "CAD$100.00"
    #
    # @example
    #   Money.new(89000, :btc).format(:drop_trailing_zeros => true) #=> B⃦0.00089
    #   Money.new(110, :usd).format(:drop_trailing_zeros => true)   #=> $1.1
    #
    # Note that the default rules can be defined through {Money.default_formatting_rules} hash.
    #
    # @see Money.default_formatting_rules Money.default_formatting_rules for more information.
    def format(*rules)
      # support for old format parameters
      rules = normalize_formatting_rules(rules)

      rules = default_formatting_rules.merge(rules)
      rules = localize_formatting_rules(rules)
      rules = translate_formatting_rules(rules) if rules[:translate]

      thousands_separator = self.thousands_separator
      decimal_mark = self.decimal_mark

      escaped_decimal_mark = Regexp.escape(decimal_mark)

      if fractional == 0
        if rules[:display_free].respond_to?(:to_str)
          return rules[:display_free]
        elsif rules[:display_free]
          return "free"
        end
      end

      symbol_value = symbol_value_from(rules)

      formatted = self.abs.to_s

      if rules[:rounded_infinite_precision]
        formatted.gsub!(/#{decimal_mark}/, '.') unless '.' == decimal_mark
        formatted = ((BigDecimal(formatted) * currency.subunit_to_unit).round / BigDecimal(currency.subunit_to_unit.to_s)).to_s("F")
        formatted.gsub!(/\..*/) do |decimal_part|
          decimal_part << '0' while decimal_part.length < (currency.decimal_places + 1)
          decimal_part
        end
        formatted.gsub!(/\./, decimal_mark) unless '.' == decimal_mark
      end

      sign = self.negative? ? '-' : ''

      if rules[:no_cents] || (rules[:no_cents_if_whole] && cents % currency.subunit_to_unit == 0)
        formatted = "#{formatted.to_i}"
      end

      # Inspiration: https://github.com/rails/rails/blob/16214d1108c31174c94503caced3855b0f6bad95/activesupport/lib/active_support/number_helper/number_to_rounded_converter.rb#L72-L79
      if rules[:drop_trailing_zeros]
        formatted = formatted.sub(/(#{escaped_decimal_mark})(\d*[1-9])?0+\z/, '\1\2').sub(/#{escaped_decimal_mark}\z/, '')
      end
      has_decimal_value = !!(formatted =~ /#{escaped_decimal_mark}/)

      thousands_separator_value = thousands_separator
      # Determine thousands_separator
      if rules.has_key?(:thousands_separator)
        thousands_separator_value = rules[:thousands_separator] || ''
      end

      # Apply thousands_separator
      formatted.gsub!(regexp_format(formatted, rules, decimal_mark, symbol_value),
                      "\\1#{thousands_separator_value}")

      symbol_position = symbol_position_from(rules)

      if rules[:sign_positive] == true && self.positive?
        sign = '+'
      end

      if rules[:sign_before_symbol] == true
        sign_before = sign
        sign = ''
      end

      if symbol_value && !symbol_value.empty?
        symbol_value = "<span class=\"currency_symbol\">#{symbol_value}</span>" if rules[:html_wrap_symbol]

        formatted = if symbol_position == :before
          symbol_space = rules[:symbol_before_without_space] === false ? " " : ""
          "#{sign_before}#{symbol_value}#{symbol_space}#{sign}#{formatted}"
        else
          symbol_space = rules[:symbol_after_without_space] ? "" : " "
          "#{sign_before}#{sign}#{formatted}#{symbol_space}#{symbol_value}"
        end
      else
        formatted="#{sign_before}#{sign}#{formatted}"
      end

      apply_decimal_mark_from_rules(formatted, rules) if has_decimal_value

      if rules[:with_currency]
        formatted << " "
        formatted << '<span class="currency">' if rules[:html]
        formatted << currency.to_s
        formatted << '</span>' if rules[:html]
      end
      formatted
    end

    def thousands_separator
      i18n_format_for(:thousands_separator, :delimiter, ",")
    end

    def decimal_mark
      i18n_format_for(:decimal_mark, :separator, ".")
    end

    alias_method :delimiter, :thousands_separator
    alias_method :separator, :decimal_mark

    private

    def i18n_format_for(method, name, character)
      if self.class.use_i18n
        begin
          I18n.t name, :scope => "number.currency.format", :raise => true
        rescue I18n::MissingTranslationData
          I18n.t name, :scope =>"number.format", :default => (currency.send(method) || character)
        end
      else
        currency.send(method) || character
      end
    end

    # Cleans up formatting rules.
    #
    # @param [Hash] rules
    #
    # @return [Hash]
    def normalize_formatting_rules(rules)
      if rules.size == 0
        rules = {}
      elsif rules.size == 1
        rules = rules.pop
        rules = { rules => true } if rules.is_a?(Symbol)
      end
      if !rules.include?(:decimal_mark) && rules.include?(:separator)
        rules[:decimal_mark] = rules[:separator]
      end
      if !rules.include?(:thousands_separator) && rules.include?(:delimiter)
        rules[:thousands_separator] = rules[:delimiter]
      end
      rules
    end

    # Applies decimal mark from rules to formatted
    #
    # @param [String] formatted
    # @param [Hash]   rules
    def apply_decimal_mark_from_rules(formatted, rules)
      if rules.has_key?(:decimal_mark) && rules[:decimal_mark] &&
        rules[:decimal_mark] != decimal_mark

        regexp_decimal = Regexp.escape(decimal_mark)
        formatted.sub!(/(.*)(#{regexp_decimal})(.*)\Z/,
                       "\\1#{rules[:decimal_mark]}\\3")
      end
    end
  end

  def default_formatting_rules
    self.class.default_formatting_rules || {}
  end

  def regexp_format(formatted, rules, decimal_mark, symbol_value)
    regexp_decimal = Regexp.escape(decimal_mark)
    if rules[:south_asian_number_formatting]
      /(\d+?)(?=(\d\d)+(\d)(?:\.))/
    else
      # Symbols may contain decimal marks (E.g "դր.")
      if formatted.sub(symbol_value.to_s, "") =~ /#{regexp_decimal}/
        /(\d)(?=(?:\d{3})+(?:#{regexp_decimal}))/
      else
        /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
      end
    end
  end

  def translate_formatting_rules(rules)
    begin
      rules[:symbol] = I18n.t currency.iso_code, :scope => "number.currency.symbol", :raise => true
    rescue I18n::MissingTranslationData
      # Do nothing
    end
    rules
  end

  def localize_formatting_rules(rules)
    if currency.iso_code == "JPY" && I18n.locale == :ja
      rules[:symbol] = "円" unless rules[:symbol] == false
      rules[:symbol_position] = :after
      rules[:symbol_after_without_space] = true
    end
    rules
  end

  def symbol_value_from(rules)
    if rules.has_key?(:symbol)
      if rules[:symbol] === true
        if rules[:disambiguate] && currency.disambiguate_symbol
          currency.disambiguate_symbol
        else
          symbol
        end
      elsif rules[:symbol]
        rules[:symbol]
      else
        ""
      end
    elsif rules[:html]
      currency.html_entity == '' ? currency.symbol : currency.html_entity
    elsif rules[:disambiguate] && currency.disambiguate_symbol
      currency.disambiguate_symbol
    else
      symbol
    end
  end

  def symbol_position_from(rules)
    if rules.has_key?(:symbol_position)
      if [:before, :after].include?(rules[:symbol_position])
        return rules[:symbol_position]
      else
        raise ArgumentError, ":symbol_position must be ':before' or ':after'"
      end
    elsif currency.symbol_first?
      :before
    else
      :after
    end
  end
end
