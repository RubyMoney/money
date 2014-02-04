# encoding: UTF-8

require "money/money/formatter"

class Money
  module Formatting
    def self.included(base)
      [
        [:thousands_separator, :delimiter, "."],
        [:decimal_mark, :separator, ","]
      ].each do |method, name, character|
        define_i18n_method(method, name, character)
      end
    end

    def self.define_i18n_method(method, name, character)
      define_method(method) do
        if self.class.use_i18n
          I18n.t(
            :"number.currency.format.#{name}", :default => I18n.t(
              :"number.format.#{name}",
              :default => (currency.send(method) || character)
            )
          )
        else
          currency.send(method) || character
        end
      end
      alias_method name, method
    end

    # Creates a formatted price string according to several rules.
    #
    # @param [Hash] rules The options used to format the string.
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
    #   Money.ca_dollar(100).format #=> "$1.00"
    #   Money.ca_dollar(100).format(:with_currency => true) #=> "$1.00 CAD"
    #   Money.us_dollar(85).format(:with_currency => true)  #=> "$0.85 USD"
    #
    # @option *rules [Boolean] :rounded_infinite_precision (false) Whether the
    #  amount of money should be rounded when using infinite_precision
    #
    # @example
    #   Money.us_dollar(100.1).format #=> "$1.001"
    #   Money.us_dollar(100.1).format(:rounded_infinite_precision => true) #=> "$1"
    #   Money.us_dollar(100.9).format(:rounded_infinite_precision => true) #=> "$1.01"
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
    #   # You can specify a indian currency format
    #   Money.new(10000000, "INR").format(:south_asian_number_formatting => true) #=> "1,00,000.00"
    #   Money.new(10000000).format(:south_asian_number_formatting => true) #=> "$1,00,000.00"
    #
    # @option *rules [Boolean, nil] :symbol_before_without_space (true) Whether
    # a space between the money symbol and the amount should be inserted when
    # +:symbol_position+ is +:before+. The default is true (meaning no space). Ignored
    # if +:symbol+ is false or +:symbol_position+ is not +:before+.
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
    # @option *rules [Boolean, nil] :symbol_after_without_space (false) Whether
    # a space between the the amount and the money symbol should be inserted when
    # +:symbol_position+ is +:after+. The default is false (meaning space). Ignored
    # if +:symbol+ is false or +:symbol_position+ is not +:after+.
    #
    # @example
    #   # Default is to insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after) #=> "1.00 $"
    #
    #   # If set to true, will not insert a space.
    #   Money.new(100, "USD").format(:symbol_position => :after, :symbol_after_without_space => true) #=> "1.00$"
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
    #
    # @option *rules [Boolean] :sign_before_symbol (false) Whether the sign should be
    #  before the currency symbol.
    #
    # @example
    #   # You can specify to display the sign before the symbol for negative numbers
    #   Money.new(-100, "GBP").format(:sign_before_symbol => true)  #=> "-£1.00"
    #   Money.new(-100, "GBP").format(:sign_before_symbol => false) #=> "£-1.00"
    #   Money.new(-100, "GBP").format                               #=> "£-1.00"
    #
    # @option *rules [Boolean] :sign_positive (false) Whether positive numbers should be
    #  signed, too.
    #
    # @example
    #   # You can specify to display the sign with positive numbers
    #   Money.new(100, "GBP").format(:sign_positive => true,  :sign_before_symbol => true)  #=> "+£1.00"
    #   Money.new(100, "GBP").format(:sign_positive => true,  :sign_before_symbol => false) #=> "£+1.00"
    #   Money.new(100, "GBP").format(:sign_positive => false, :sign_before_symbol => true)  #=> "£1.00"
    #   Money.new(100, "GBP").format(:sign_positive => false, :sign_before_symbol => false) #=> "£1.00"
    #   Money.new(100, "GBP").format                               #=> "£+1.00"

    def format(*rules)
      formatter = Money::Formatter.new(self, rules)
      formatter.format
    end
  end
end
