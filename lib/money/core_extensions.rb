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
    cents = calculate_cents(self)
    Money.new(cents, currency)
  end
  
  private
  
  def calculate_cents(number)
    num = number.gsub(/[^\d|\.|,|\'|\s|\-]/, '').strip
    negative = num.split(//).first == "-"
    num = num.gsub(/^-/, '') if negative
    
    used_separators = num.scan /[^\d]/
    
    case used_separators.uniq.length
    when 0
      major, minor = num, 0
    when 1
      separator = used_separators.first
      # can't determine initially, try to infer
      if num.scan(/^((\d{1,3})(#{separator}\d{3})*)$/).any? || num.scan(separator).length > 1 # standard currency format || multiple matches; treat as separator
        major, minor = num.gsub(separator, ''), 0
      else
        # ex: 1,000 - 1.0000 - 10001.000
        possible_major, possible_minor = num.split(separator)
        
        if possible_minor.length != 3 # delimiter
          major, minor = possible_major, possible_minor
        else
          if possible_major.length > 3 # delimiter (1000,000)
            major, minor = possible_major, possible_minor
          else
            # handle as , is sep, . is delimiter
            if used_separator == '.'
              major, minor = possible_major, possible_minor
            else
              major, minor = "#{possible_major}#{possible_minor}", 0
            end
          end
        end
      end
    when 2
      separator, delimiter = used_separators.uniq
      major, minor = num.gsub(separator, '').split(delimiter)
      min = 0 unless min
    else
      raise ArgumentError, "Invalid currency amount"
    end
    
    cents = "#{major}.#{minor}".to_f * 100
    
    negative ? cents * -1 : cents
  end
  
end
