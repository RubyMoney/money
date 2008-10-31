class NoExchangeBank# :nodoc:

  def reduce(money, currency)
    return money if money.currency == currency
    raise Money::MoneyError.new("Current Money::bank does not support money exchange. Please implement a bank object that does and assign it to the Money class.")
  end
  
  
end