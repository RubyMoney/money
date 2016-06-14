COIN_I2F = 100_000_000
MONEY_I2F = 100_000
MONEY_DELTA = 1_000

class Integer

  # Convert number from big integer value to float value.
  #
  # @param [String] currency
  # @param [Hash] opts
  #
  # @return [Float]
  #
  # @example
  #   123456789.to_float('btc') => 1.23456789
  #   123456789.to_float('cny') => 1234.56789

  def to_float(currency, opts = {})
    case currency.to_s
    when 'btc', 'eth'
      normalize_coin(currency, opts)
    when 'cny', 'twd', 'usd'
      normalize_money(currency, opts)
    else
      # do everything else now, assume money
      normalize_money(currency, opts)
      # raise Money::Currency::UnknownCurrency, currency.inspect
    end
  end


  # Convert number from big integer value to floor or ceil value.
  #
  # @param [String] currency
  # @param [Hash] opts
  #
  # @return [Integer]
  #
  # @example
  #   (123426845).to_integer('cny', ceil: true) => 1234270000
  #   (123426345).to_integer('twd', floor: true) => 1234260000
  #
  # @notes The :ceil and :floor approximate to the second decimal place.

  def to_integer(currency, opts = {})
    case currency.to_s
    when 'btc', 'eth'
      self
    else
    #when 'cny', 'twd', 'usd'
      if opts[:ceil]
        (self.to_f / MONEY_DELTA).ceil * MONEY_DELTA
      elsif opts[:floor]
        (self.to_f / MONEY_DELTA).floor * MONEY_DELTA
      end
    #else
    #  raise Money::Currency::UnknownCurrency, currency.inspect
    end
  end


  # Convert number from big integer value to string value.
  #
  # @param [String] currency
  # @param [Hash] opts
  #
  # @return [String]
  #
  # @example
  #   123456789.to_string('btc') => "1.23456789 BTC"
  #   123456789.to_string('twd') => "NT$1,234.57"
  #   123456789.to_string('twd', ceil: true) => "NT$1,235.00"
  #   123456789.to_string('twd', round: true) => "NT$1,235"
  #   123456789.to_string('twd', floor: true) => "NT$1,234.00"
  #
  # @notes The :round, :ceil and :floor approximate to digit in ones.

  def to_string(currency, opts = {})
    case currency.to_s
    when 'btc', 'eth'
      stringify_coin(currency, opts)
    when 'cny', 'twd', 'usd'
      stringify_money(currency, opts)
    else
      # do everything else too, assume money
      stringify_money(currency, opts)
      # raise Money::Currency::UnknownCurrency, currency.inspect
    end
  end

  private

  def normalize_coin(currency, opts = {})
    self.to_f / COIN_I2F
  end

  def normalize_money(currency, opts = {})
    self.to_f / MONEY_I2F
  end

  def stringify_coin(currency, opts = {})
    currency_object = Money::Currency.new currency
    amount = self.to_f * currency_object.subunit_to_unit / COIN_I2F
    Money.new(amount, currency).format default_coin_options.merge(opts)
  end

  def stringify_money(currency, opts = {})
    currency_object = Money::Currency.new currency
    delta = currency_object.subunit_to_unit
    amount = self.to_f * delta / MONEY_I2F

    if opts[:round]
      amount = (amount/delta).round * delta
      opts = opts.merge(no_cents: true)
    end

    if opts[:ceil]
      amount = (amount/delta).ceil * delta
    end

    if opts[:floor]
      amount = (amount/delta).floor * delta
    end

    Money.new(amount, currency).format default_money_options.merge(opts)
  end

  def default_money_options
    { disambiguate: true }
  end

  def default_coin_options
    { symbol: false, with_currency: true }
  end

end


class Float

  # Convert number from float value to big integer value.
  #
  # @param [String] currency
  # @param [Hash] opts
  #
  # @return [Integer]
  #
  # @example
  #   (1.23456789).to_integer('btc') => 123456789
  #   (1.23456789).to_integer('twd') => 123457

  def to_integer(currency, opts = {})
    case currency.to_s
    when 'btc', 'eth'
      unnormalize_coin(opts)
    when 'cny', 'twd', 'usd'
      unnormalize_money(opts)
    else
      # assume money
      unnormalize_money(opts)
      # raise Money::Currency::UnknownCurrency, currency.inspect
    end
  end

  # Convert number from float value to string value.
  #
  # @param [String] currency
  # @param [Hash] opts
  #
  # @return [String]
  #
  # @notes Equivalent to self.to_integer(currency).to_string(currency, opts)
  def to_string(currency, opts = {})
    self.to_integer(currency).to_string(currency, opts)
  end

  private

  def unnormalize_coin(opts = {})
    (self * COIN_I2F).round
  end

  def unnormalize_money(opts = {})
    (self * MONEY_I2F).round
  end

end
