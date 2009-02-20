class Numeric
  # Converts this numeric to a Money object in the default currency. It
  # multiplies the numeric value by 100 and treats that as cents.
  #
  #   100.to_money => #<Money @cents=10000>
  #   100.37.to_money => #<Money @cents=10037>
  def to_money
    Money.new(self * 100)
  end
end

class String
  # Parses the current string and converts it to a Money object.
  # Excess characters will be discarded.
  #
  #   '100'.to_money       # => #<Money @cents=10000>
  #   '100.37'.to_money    # => #<Money @cents=10037>
  #   '100 USD'.to_money   # => #<Money @cents=10000, @currency="USD">
  #   'USD 100'.to_money   # => #<Money @cents=10000, @currency="USD">
  #   '$100 USD'.to_money   # => #<Money @cents=10000, @currency="USD">
  def to_money
    # Get the currency.
    matches = scan /([A-Z]{2,3})/ 
    currency = matches[0] ? matches[0][0] : Money.default_currency
    
    result = self.gsub(/\s+/, '').scan /\-?\d+[\.,]?/
    cents = if result.length >= 1
      while(result[-2] && result[-2].scan(/,|\./).empty?) do
        result.pop
      end
      
      no_cents_parsed = result.last.length == 3
      
      result = result.map {|delimited| delimited.gsub(/,|\.|\'/, '') }
      conv_to_i = lambda {|arr| arr.join.to_i }
      
      result.length == 1 || no_cents_parsed ? conv_to_i.call(result) * 100 : conv_to_i.call(result)
    else
      0
    end
    
    Money.new(cents, currency)
  end
end
