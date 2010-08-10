require 'money/bank/base'

class Money
  module Bank

    # Class for aiding in exchanging money between different currencies.
    # By default, the Money class uses an object of this class (accessible through
    # Money#bank) for performing currency exchanges.
    #
    # By default, Bank::VariableExchange has no knowledge about conversion rates.
    # One must manually specify them with +add_rate+, after which one can perform
    # exchanges with +exchange+. For example:
    #
    #   bank = Money::Bank::VariableExchange.new
    #   bank.add_rate("USD", "CAD", 1.24515)
    #   bank.add_rate("CAD", "USD", 0.803115)
    #
    #   # Exchange 100 CAD to USD:
    #   bank.exchange(100_00, "CAD", "USD")  # => 124
    #   # Exchange 100 USD to CAD:
    #   bank.exchange(100_00, "USD", "CAD")  # => 80
    #
    class VariableExchange < Base

      def initialize(&block)
        @rates = {}
        @mutex = Mutex.new
        super
      end


      # Exchanges the given +Money+ object to a new +Money+ object in
      # +to_currency+. Returns a new +Money+ object.
      #
      # Raises <tt>Money::Bank::UnknownRate</tt> if the conversion rate is unknown.
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


      # Registers a conversion rate. +from+ and +to+ are both currency names or
      # +Currency+ objects.
      def add_rate(from, to, rate)
        set_rate(from, to, rate)
      end

      # Set the rate for the given currencies.
      def set_rate(from, to, rate)
        @mutex.synchronize { @rates[rate_key_for(from, to)] = rate }
      end

      # Retrieve the rate for the given currencies.
      def get_rate(from, to)
        @mutex.synchronize { @rates[rate_key_for(from, to)] }
      end

      private

        # Return the rate hashkey for the given currencies.
        def rate_key_for(from, to)
          "#{Currency.wrap(from).iso_code}_TO_#{Currency.wrap(to).iso_code}".upcase
        end

    end

  end
end
