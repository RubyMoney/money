# encoding: utf-8
require "money/currency"

class Money

  # Represents a currency pair
  class CurrencyPair

    attr :base, :counter

    # Wraps the object in a +CurrencyPair+ unless it's already a +CurrencyPair+
    # object.
    #
    # @param [Object] object The object to attempt and wrap as a +Currency+
    # object.
    #
    # @return [Money::CurrencyPair]
    #
    # @example
    #   pair = Money::CurrencyPair.new(:aud, :nzd)
    #   Money::CurrencyPair.wrap(nil)   #=> nil
    #   Money::CurrencyPair.wrap(pair)    #=> #<Money::CurrencyPair id: usd ...>
    #   Money::CurrencyPair.wrap("usd") #=> #<Money::CurrencyPair id: usd ...>

    def self.wrap(object)
      if object.is_a?(CurrencyPair)
        object
      elsif object.is_a?(String) && object.length == 6
        new(object[0..2], object[3..5])
      elsif object.is_a?(Symbol) && object.length == 6
        new(object.to_s[0..2], object.to_s[3..5])
      else
        nil
      end
    end

    # Create a new +CurrencyPair+ object.
    #
    # @param [String, Symbol, Currency] base_currency The currency pair's base currency
    # @param [String, Symbol, Currency] counter_currency The currency pair's counter currency
    #
    # @return [Money::CurrencyPair]
    #
    # @example
    #   Money::CurrencyPair.new(:aud, :nzd) #=> #<Money::CurrencyPair base: aud, counter: nzd ...>
    def initialize(base_currency, counter_currency)
      @base = Currency.wrap(base_currency)
      @counter = Currency.wrap(counter_currency)
    end

    def to_s
      [base.iso_code, counter.iso_code].join
    end

    # Returns the inverse of the currency pair
    def inverse
      self.class.new(counter, base)
    end

    def eql?(other_currency)
      self.==(other_currency)
    end

    def ==(other)
      base == other.base && counter == other.counter
    end
  end
end
