class String
  # Get the name of currency
  #
  # @param [String] currency
  #
  # @return [String]
  #
  # @example
  #   'btc'.to_name => 'BTC'
  def to_name
    case self.to_s
    when 'btc', 'eth'
      Money::Currency.new(self).to_s
    else
    #when 'cny', 'twd', 'usd'
      Money::Currency.new(self).name
    #else
    #  raise Money::Currency::UnknownCurrency, currency.inspect
    end
  end

  # Get the symbol of currency
  #
  # @param
  #
  # @return [String]
  #
  # @example
  #   'cny'.to_symbol => '¥'
  #   'twd'.to_symbol => 'NT$'
  #   'usd'.to_symbol => '$'
  def to_symbol
    Money::Currency.new(self).disambiguate_symbol || Money::Currency.new(self).symbol
  end
end
