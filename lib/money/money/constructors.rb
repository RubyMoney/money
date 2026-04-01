# frozen_string_literal: true

class Money
  module Constructors
    # Creates a new Money object with value 0.
    #
    # @param [Currency, String, Symbol] currency The currency to use.
    #
    # @return [Money]
    #
    # @example
    #   Money.empty #=> #<Money @fractional=0>
    def empty(currency = default_currency)
      new(0, currency)
    end

    alias zero empty

    # Creates a new Money object of value given in the +unit+ of the given
    # +currency+.
    #
    # @param [Numeric] amount The numerical value of the money.
    # @param [Currency, String, Symbol] currency The currency format.
    # @param [Hash] options Optional settings for the new Money instance
    # @option [Money::Bank::*] :bank The exchange bank to use.
    #
    # @example
    #   Money.from_amount(23.45, "USD") # => #<Money fractional:2345 currency:USD>
    #   Money.from_amount(23.45, "JPY") # => #<Money fractional:23 currency:JPY>
    #
    # @return [Money]
    #
    # @see #initialize
    def from_amount(amount, currency = default_currency, options = {})
      raise ArgumentError, "'amount' must be numeric" unless amount.is_a?(Numeric)

      currency = Currency.wrap(currency) || Money.default_currency
      raise Currency::NoCurrency, "must provide a currency" if currency.nil?

      value = amount.to_d * currency.subunit_to_unit
      new(value, currency, options)
    end

    # DEPRECATED.
    #
    # @see Money.from_amount
    def from_dollars(amount, currency = default_currency, options = {})
      warn "[DEPRECATION] `Money.from_dollars` is deprecated in favor of " \
           "`Money.from_amount`."

      from_amount(amount, currency, options)
    end
  end
end
