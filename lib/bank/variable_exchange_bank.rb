# Example useage:
#
#  Money.bank = VariableExchangeBank.new
#  Money.bank.add_rate("USD", "CAD", 1.24515)
#  Money.bank.add_rate("CAD", "USD", 0.803115)
#  Money.us_dollar(100).exchange_to("CAD") => Money.ca_dollar(124)
#  Money.ca_dollar(100).exchange_to("USD") => Money.us_dollar(80)
class VariableExchangeBank 
   
  def add_rate(from, to, rate)
    rates["#{from}_TO_#{to}".upcase] = rate
  end
  
  def get_rate(from, to)
    rates["#{from}_TO_#{to}".upcase] 
  end
  
  def reduce(money, currency)
    rate = get_rate(money.currency, currency) or raise Money::MoneyError.new("Can't find required exchange rate")
    
    Money.new((money.cents * rate).floor, currency)
  end
  
  private
  
  def rates
    @rates ||= {} 
  end
  
end