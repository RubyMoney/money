# encoding: UTF-8
class Money
  module Formatting

    if Object.const_defined?("I18n")
      def thousands_separator
        if self.class.use_i18n
          I18n.t(
            :"number.currency.format.delimiter",
            :default => I18n.t(
              :"number.format.delimiter",
              :default => (currency.thousands_separator || ",")
            )
          )
        else
          currency.thousands_separator || ","
        end
      end
    else
      def thousands_separator
        currency.thousands_separator || ","
      end
    end
    alias :delimiter :thousands_separator


    if Object.const_defined?("I18n")
      def decimal_mark
        if self.class.use_i18n
          I18n.t(
            :"number.currency.format.separator",
            :default => I18n.t(
              :"number.format.separator",
              :default => (currency.decimal_mark || ".")
            )
          )
        else
          currency.decimal_mark || "."
        end
      end
    else
      def decimal_mark
        currency.decimal_mark || "."
      end
    end
    alias :separator :decimal_mark

    # Creates a formatted price string according to several rules.
    #
    # @param [Hash] *rules The options used to format the string.
    #
    # @return [String]
    #
    # @option *rules [Boolean, String] :display_free (false) Whether a zero
    #  amount of money should be formatted of "free" or as the supplied string.
    #
    # @example
    #   Money.us_dollar(0).format(:display_free => true)     #=> "free"
    #   Money.us_dollar(0).format(:display_free => "gratis") #=> "gratis"
    #   Money.us_dollar(0).format                            #=> "$0.00"
    #
    # @option *rules [Boolean] :with_currency (false) Whether the currency name
    #  should be appended to the result string.
    #
    # @example
    #   Money.ca_dollar(100).format => "$1.00"
    #   Money.ca_dollar(100).format(:with_currency => true) #=> "$1.00 CAD"
    #   Money.us_dollar(85).format(:with_currency => true)  #=> "$0.85 USD"
    #
    # @option *rules [Boolean] :no_cents (false) Whether cents should be omitted.
    #
    # @example
    #   Money.ca_dollar(100).format(:no_cents => true) #=> "$1"
    #   Money.ca_dollar(599).format(:no_cents => true) #=> "$5"
    #
    # @option *rules [Boolean] :no_cents_if_whole (false) Whether cents should be 
    #  omitted if the cent value is zero
    #
    # @example
    #   Money.ca_dollar(10000).format(:no_cents_if_whole => true) #=> "$100"
    #   Money.ca_dollar(10034).format(:no_cents_if_whole => true) #=> "$100.34"
    #
    # @option *rules [Boolean, String, nil] :symbol (true) Whether a money symbol
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
    # @option *rules [Boolean, String, nil] :decimal_mark (true) Whether the
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
    # @option *rules [Boolean, String, nil] :thousands_separator (true) Whether
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
    # @option *rules [Boolean] :html (false) Whether the currency should be
    #  HTML-formatted. Only useful in combination with +:with_currency+.
    #
    # @example
    #   s = Money.ca_dollar(570).format(:html => true, :with_currency => true)
    #   s #=>  "$5.70 <span class=\"currency\">CAD</span>"
    def format(*rules)
      # support for old format parameters
      rules = normalize_formatting_rules(rules)
      rules = localize_formatting_rules(rules)

      if cents == 0
        if rules[:display_free].respond_to?(:to_str)
          return rules[:display_free]
        elsif rules[:display_free]
          return "free"
        end
      end

      symbol_value =
        if rules.has_key?(:symbol)
          if rules[:symbol] === true
            symbol
          elsif rules[:symbol]
            rules[:symbol]
          else
            ""
          end
        elsif rules[:html]
          currency.html_entity == '' ? currency.symbol : currency.html_entity
        else
          symbol
        end

      formatted = rules[:no_cents] ? "#{self.to_s.to_i}" : self.to_s

      if rules[:no_cents_if_whole] && cents % currency.subunit_to_unit == 0
        formatted = "#{self.to_s.to_i}"
      end

      symbol_position =
        if rules.has_key?(:symbol_position)
          rules[:symbol_position]
        elsif currency.symbol_first?
          :before
        else
          :after
        end

      if symbol_value && !symbol_value.empty?
        formatted = if symbol_position == :before 
          "#{symbol_value}#{formatted}"
        else
          symbol_space = rules[:symbol_after_without_space] ? "" : " "
          "#{formatted}#{symbol_space}#{symbol_value}"
        end
      end

      if rules.has_key?(:decimal_mark) and rules[:decimal_mark] and
        rules[:decimal_mark] != decimal_mark
        formatted.sub!(decimal_mark, rules[:decimal_mark])
      end

      thousands_separator_value = thousands_separator
      # Determine thousands_separator
      if rules.has_key?(:thousands_separator)
        thousands_separator_value = rules[:thousands_separator] || ''
      end

      # Apply thousands_separator
      regexp_decimal = Regexp.escape(decimal_mark)
      regexp_format  = if formatted =~ /#{regexp_decimal}/
           /(\d)(?=(?:\d{3})+(?:#{regexp_decimal}))/
         else
           /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
         end
      formatted.gsub!(regexp_format, "\\1#{thousands_separator_value}")

      if rules[:with_currency]
        formatted << " "
        formatted << '<span class="currency">' if rules[:html]
        formatted << currency.to_s
        formatted << '</span>' if rules[:html]
      end
      formatted
    end


    private

    # Cleans up formatting rules.
    #
    # @param [Hash]
    #
    # @return [Hash]
    def normalize_formatting_rules(rules)
      if rules.size == 0
        rules = {}
      elsif rules.size == 1
        rules = rules.pop
        rules = { rules => true } if rules.is_a?(Symbol)
      end
      if not rules.include?(:decimal_mark) and rules.include?(:separator)
        rules[:decimal_mark] = rules[:separator]
      end
      if not rules.include?(:thousands_separator) and rules.include?(:delimiter)
        rules[:thousands_separator] = rules[:delimiter]
      end
      rules
    end
  end

  def localize_formatting_rules(rules)
    if currency.iso_code == "JPY" && I18n.locale == :ja
      rules[:symbol] = "円"
      rules[:symbol_position] = :after
      rules[:symbol_after_without_space] = true
    end
    rules
  end
end
