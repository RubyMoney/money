require 'thread'

class Money
  module Bank

    class UnknownRate < StandardError; end

    # Class for aiding in the creating of other classes to exchange money between
    # different currencies.
    #
    # When creating a subclass you will need to define methods to populate the
    # +@rates+ hash using +#set_rate+ and +#get_rate+, or override the
    # +#exchange_with+ method.
    #
    # See Money::Bank::VariableExchange for an example.
    class Base

      # Returns the singleton instance of the Base bank.
      def self.instance
        @@singleton
      end

      @@singleton = self.new

      def initialize(&block)
        @rates = {}
        @mutex = Mutex.new
        @rounding_method = block
      end

      # @depreciated +#exchange+ will be removed in v3.2.0, use +#exchange_with+
      #
      # Exchange the given amount of cents in +from_currency+ to +to_currency+.
      # Returns the amount of cents in +to_currency+ as an integer, rounded down.
      #
      # If the conversion rate is unknown, +UnknownRate+ will be raised.
      def exchange(cents, from_currency, to_currency, &block)
        warn '[DEPRECIATION] `exchange` will be removed in v3.2.0, use #exchange_with instead'
        exchange_with(Money.new(cents, from_currency), to_currency, &block).cents
      end

      # Exchange the given +Money+ object to a new +Money+ object in
      # +to_currency+. Returns a new +Money+ object.
      #
      # If the conversion rate is unknown, +UknownRate+ will be raised.
      def exchange_with(from, to_currency, &block)
        return from if same_currency?(from.currency, to_currency)

        rate = get_rate(from.currency, to_currency)
        unless rate
          raise UnknownRate, "No conversion rate known for '#{from.currency.iso_code}' -> '#{to_currency}'"
        end
        _to_currency_  = Currency.wrap(to_currency)

        cents = from.cents / (from.currency.subunit_to_unit.to_f / _to_currency_.subunit_to_unit.to_f)

        ex = cents * rate
        ex = if block_given?
               block.call(ex)
             elsif @rounding_method
               @rounding_method.call(ex)
             else
               ex.to_s.to_i
             end
        Money.new(ex, _to_currency_)
      end

      private

      # Return the rate hashkey for the given currencies.
      def rate_key_for(from, to)
        "#{Currency.wrap(from).iso_code}_TO_#{Currency.wrap(to).iso_code}".upcase
      end

      # Set the rate for the given currencies.
      def set_rate(from, to, rate)
        @mutex.synchronize { @rates[rate_key_for(from, to)] = rate }
      end

      # Retrieve the rate for the given currencies.
      def get_rate(from, to)
        @mutex.synchronize { @rates[rate_key_for(from, to)] }
      end

      # Return +true+ if the currencies are the same, +false+ otherwise.
      def same_currency?(currency1, currency2)
        Currency.wrap(currency1) == Currency.wrap(currency2)
      end
    end

  end
end
