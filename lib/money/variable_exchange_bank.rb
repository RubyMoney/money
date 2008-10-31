require 'thread'
require 'money/errors'

# Class for aiding in exchanging money between different currencies.
# By default, the Money class uses an object of this class (accessible through
# Money#bank) for performing currency exchanges.
#
# By default, VariableExchangeBank has no knowledge about conversion rates.
# One must manually specify them with +add_rate+, after which one can perform
# exchanges with +exchange+. For example:
#
#  bank = Money::VariableExchangeBank.new
#  bank.add_rate("USD", "CAD", 1.24515)
#  bank.add_rate("CAD", "USD", 0.803115)
#  
#  # Exchange 100 CAD to USD:
#  bank.exchange(100_00, "CAD", "USD")  # => 124
#  # Exchange 100 USD to CAD:
#  bank.exchange(100_00, "USD", "CAD")  # => 80
class Money
  class VariableExchangeBank
    # Returns the singleton instance of VariableExchangeBank.
    #
    # By default, <tt>Money.default_bank</tt> returns the same object.
    def self.instance
      @@singleton
    end
    
    def initialize
      @rates = {}
      @mutex = Mutex.new
    end
    
    # Registers a conversion rate. +from+ and +to+ are both currency names.
    def add_rate(from, to, rate)
      @mutex.synchronize do
        @rates["#{from}_TO_#{to}".upcase] = rate
      end
    end
    
    # Gets the rate for exchanging the currency named +from+ to the currency
    # named +to+. Returns nil if the rate is unknown.
    def get_rate(from, to)
      @mutex.synchronize do
        @rates["#{from}_TO_#{to}".upcase] 
      end
    end
    
    # Given two currency names, checks whether they're both the same currency.
    #
    #   bank = VariableExchangeBank.new
    #   bank.same_currency?("usd", "USD")   # => true
    #   bank.same_currency?("usd", "EUR")   # => false
    def same_currency?(currency1, currency2)
      currency1.upcase == currency2.upcase
    end
    
    # Exchange the given amount of cents in +from_currency+ to +to_currency+.
    # Returns the amount of cents in +to_currency+ as an integer, rounded down.
    #
    # If the conversion rate is unknown, then Money::UnknownRate will be raised.
    def exchange(cents, from_currency, to_currency)
      rate = get_rate(from_currency, to_currency)
      if !rate
        raise Money::UnknownRate, "No conversion rate known for '#{from_currency}' -> '#{to_currency}'"
      end
      (cents * rate).floor
    end
    
    @@singleton = VariableExchangeBank.new
  end
end
