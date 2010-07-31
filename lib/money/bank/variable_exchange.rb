require 'money/bank/base'

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
class Money
  module Bank

    class VariableExchange < Base
      @@singleton = VariableExchange.new

      # Registers a conversion rate. +from+ and +to+ are both currency names or
      # +Currency+ objects.
      def add_rate(from, to, rate)
        set_rate(from, to, rate)
      end
    end

  end
end
