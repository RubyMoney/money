class String
  # Get the name of currency
  #
  # @param [String] currency
  #
  # @return [String]
  #
  # @example
  #   'btc'.to_name => 'Bitcoin'
  #   'eth'.to_name => 'Ether'
  #   'twd'.to_name => 'New Taiwan Dollar'
  #   'usd'.to_name => 'United States Dollar'
  def to_name
    Money::Currency.new(self).name
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
