class String
  # Get the name of currency
  #
  # @param [String] currency
  #
  # @return [String]
  #
  # @example
  #   'btc'.to_currency_name => 'Bitcoin'
  #   'eth'.to_currency_name => 'Ether'
  #   'twd'.to_currency_name => 'New Taiwan Dollar'
  #   'usd'.to_currency_name => 'United States Dollar'
  def to_currency_name
    Money::Currency.new(self).name
  end

  # Get the symbol of currency
  #
  # @param
  #
  # @return [String]
  #
  # @example
  #   'cny'.to_currency_symbol => '¥'
  #   'twd'.to_currency_symbol => 'NT$'
  #   'usd'.to_currency_symbol => '$'
  def to_currency_symbol
    Money::Currency.new(self).disambiguate_symbol || Money::Currency.new(self).symbol
  end
end
