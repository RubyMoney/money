require 'thread'

class Money
  module Bank

    # The lowest Money::Bank error class.
    # All Money::Bank errors should inherit from it.
    class Error < StandardError
    end

    # Raised when the bank doesn't know about the conversion rate
    # for specified currencies.
    class UnknownRate < Error
    end


    #
    # Money::Bank::Base is the basic interface for creating a money exchange object,
    # also called Bank.
    #
    # A Bank is responsible for storing exchange rates,
    # take a Money object as input and returns the corresponding Money object
    # converted into an other currency.
    #
    # This class exists for aiding in the creating of other classes to exchange money between
    # different currencies. When creating a subclass you will need to implement
    # the following  methods to exchange money between currencies:
    #
    # * #exchange_with(Money) # => Money
    #
    # See Money::Bank::VariableExchange for a real example.
    #
    # Also, you can extend Money::Bank::VariableExchange
    # instead of Money::Bank::Base if your bank implementation
    # needs to store rates internally.
    #
    class Base

      # Returns the singleton instance of the Base bank.
      def self.instance
        @@singleton ||= self.new
      end

      attr_reader :rounding_method

      # Initializes a new Money::Bank::Base object. An optional block can be
      # passed to dictate the rounding method that +exchange_with+ can use.
      def initialize(&block)
        @rounding_method = block
      end

      # @deprecated +#exchange+ will be removed in v3.2.0, use +#exchange_with+
      #
      # Exchanges the given amount of cents in +from_currency+ to +to_currency+.
      #
      # Returns the amount of cents in +to_currency+ as an integer, rounded down.
      def exchange(cents, from_currency, to_currency, &block)
        Money.deprecate "`Money::Bank::Base#exchange' will be removed in v3.2.0, use #exchange_with instead"
        exchange_with(Money.new(cents, from_currency), to_currency, &block).cents
      end

      # Exchanges the given +Money+ object to a new +Money+ object in
      # +to_currency+.
      #
      # You should implement this in a subclass,
      # otherwise it will throw a NotImplementedError as a reminder.
      #
      # Returns a new +Money+ object.
      # Raises <tt>NotImplementedError</tt>.
      def exchange_with(from, to_currency, &block)
        raise NotImplementedError, "#exchange_with must be implemented"
      end


      # Given two currency strings or object,
      # checks whether they're both the same currency.
      #
      #   same_currency?("usd", "USD")                # => true
      #   same_currency?("usd", "EUR")                # => false
      #   same_currency?("usd", Currency.new("USD")   # => true
      #   same_currency?("usd", "USD")   # => true
      #
      # Return +true+ if the currencies are the same, +false+ otherwise.
      def same_currency?(currency1, currency2)
        Currency.wrap(currency1) == Currency.wrap(currency2)
      end

    end

  end
end
