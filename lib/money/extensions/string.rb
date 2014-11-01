class String

  #############################
  #
  # Coin Formatter Methods
  #
  #############################


  # Get the name of coin currency
  #
  # @param
  #
  # @return [String]
  #
  # @example
  #   'btc'.to_coin_name => 'BTC'

  def to_coin_name
    Money::Currency.new(self).to_s
  end


  #############################
  #
  # Money Formatter Methods
  #
  #############################


  # Get the name of money currency
  #
  # @param
  #
  # @return [String]
  #
  # @example
  #   'cny'.to_coin_name => 'Chinese Renminbi Yuan'
  #   'twd'.to_coin_name => 'New Taiwan Dollar'
  #   'usd'.to_coin_name => 'United States Dollar'

  def to_money_name
    Money::Currency.new(self).name
  end

  # Get the symbol of money currency
  #
  # @param
  #
  # @return [String]
  #
  # @example
  #   'cny'.to_money_symbol => '¥'
  #   'twd'.to_money_symbol => 'NT$'
  #   'twd'.to_money_symbol => '$'

  def to_money_symbol
    Money::Currency.new(self).disambiguate_symbol || Money::Currency.new(self).symbol
  end

end
