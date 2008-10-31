require 'thread'
require 'money/errors'

# Example useage:
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
    def self.instance
      @@singleton
    end
    
    def initialize
      @rates = {}
      @mutex = Mutex.new
    end
    
    def add_rate(from, to, rate)
      @mutex.synchronize do
        @rates["#{from}_TO_#{to}".upcase] = rate
      end
    end
    
    def get_rate(from, to)
      @mutex.synchronize do
        @rates["#{from}_TO_#{to}".upcase] 
      end
    end
    
    def same_currency?(currency1, currency2)
      currency1.upcase == currency2.upcase
    end
    
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
