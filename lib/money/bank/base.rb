class Money
  # Provides classes that aid in the ability of exchange one currency with
  # another.
  module Bank

    # The lowest Money::Bank error class.
    # All Money::Bank errors should inherit from it.
    class Error < StandardError
    end

    # Raised when the bank doesn't know about the conversion rate
    # for specified currencies.
    class UnknownRate < Error
    end


    # Money::Bank::Base is the basic interface for creating a money exchange
    # object, also called Bank.
    #
    # A Bank is responsible for storing exchange rates, take a Money object as
    # input and returns the corresponding Money object converted into an other
    # currency.
    #
    # This class exists for aiding in the creating of other classes to exchange
    # money between different currencies. When creating a subclass you will
    # need to implement the following methods to exchange money between
    # currencies:
    #
    # - #exchange_with(Money) #=> Money
    #
    # See Money::Bank::VariableExchange for a real example.
    #
    # Also, you can extend +Money::Bank::VariableExchange+ instead of
    # +Money::Bank::Base+ if your bank implementation needs to store rates
    # internally.
    #
    # @abstract Subclass and override +#exchange_with+ to implement a custom
    #  +Money::Bank+ class. You can also override +#setup+ instead of
    #  +#initialize+ to setup initial variables, etc.
    class Base

      # Returns the singleton instance of the Base bank.
      #
      # @return [Money::Bank::Base]
      def self.instance
        @singleton ||= self.new
      end

      # The rounding method to use when exchanging rates.
      #
      # @return [Proc]
      attr_reader :rounding_method

      # Initializes a new +Money::Bank::Base+ object. An optional block can be
      # passed to dictate the rounding method that +#exchange_with+ can use.
      #
      # @yield [n] Optional block to use when rounding after exchanging one
      #  currency for another.
      # @yieldparam [Float] n The resulting float after exchanging one currency
      #  for another.
      # @yieldreturn [Integer]
      #
      # @return [Money::Bank::Base]
      #
      # @example
      #   Money::Bank::Base.new #=> #<Money::Bank::Base @rounding_method=nil>
      #   Money::Bank::Base.new {|n|
      #     n.floor
      #   } #=> #<Money::Bank::Base @round_method=#<Proc>>
      def initialize(&block)
        @rounding_method = block
        setup
      end

      # Called after initialize. Subclasses can use this method to setup
      # variables, etc that they normally would in +#initialize+.
      #
      # @abstract Subclass and override +#setup+ to implement a custom
      #  +Money::Bank+ class.
      #
      # @return [self]
      def setup
      end

      # Exchanges the given +Money+ object to a new +Money+ object in
      # +to_currency+.
      #
      # @abstract Subclass and override +#exchange_with+ to implement a custom
      #  +Money::Bank+ class.
      #
      # @raise NotImplementedError
      #
      # @param [Money] from The +Money+ object to exchange from.
      # @param [Money::Currency, String, Symbol] to_currency The currency
      #  string or object to exchange to.
      # @yield [n] Optional block to use to round the result after making
      #  the exchange.
      # @yieldparam [Float] n The result after exchanging from one currency to
      #  the other.
      # @yieldreturn [Integer]
      #
      # @return [Money]
      def exchange_with(from, to_currency, &block)
        raise NotImplementedError, "#exchange_with must be implemented"
      end

      # Given two currency strings or object, checks whether they're both the
      # same currency. Return +true+ if the currencies are the same, +false+
      # otherwise.
      #
      # @param [Money::Currency, String, Symbol] currency1 The first currency
      #  to compare.
      # @param [Money::Currency, String, Symbol] currency2 The second currency
      #  to compare.
      #
      # @return [Boolean]
      #
      # @example
      #   same_currency?("usd", "USD")                #=> true
      #   same_currency?("usd", "EUR")                #=> false
      #   same_currency?("usd", Currency.new("USD")   #=> true
      #   same_currency?("usd", "USD")                #=> true
      def same_currency?(currency1, currency2)
        Currency.wrap(currency1) == Currency.wrap(currency2)
      end
    end
  end
end
