# Allows Writing of 100.to_money for +Numeric+ types
#   100.to_money => #<Money @cents=10000>
#   100.37.to_money => #<Money @cents=10037>
class Numeric
  def to_money
    Money.new(self * 100)
  end
end

# Allows Writing of '100'.to_money for +String+ types
# Excess characters will be discarded
#   '100'.to_money => #<Money @cents=10000>
#   '100.37'.to_money => #<Money @cents=10037>
class String
  def to_money
    # Get the currency
    matches = scan /([A-Z]{2,3})/ 
    currency = matches[0] ? matches[0][0] : Money.default_currency
    
    # Get the cents amount
    matches = scan /(\-?\d+(\.(\d+))?)/
    cents = matches[0] ? (matches[0][0].to_f * 100) : 0
    
    Money.new(cents, currency)
  end
end
