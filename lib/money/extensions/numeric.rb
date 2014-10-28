class Numeric

  #########################################################################
  #
  # Money Formatter Methods (the receiver is in big integer value)
  #
  #  - the method starts with 'to_' returns real money with currency
  #  - the method starts with 'pure_' returns real money without currency
  #  - the method starts with 'raw_' returns big integer value of money
  #
  #########################################################################


  MONEY_I2F = 100000
  MONEY_DELTA = 1000


  # Convert money from big integer value to currency value.
  #
  # @param [String] money_type
  #
  # @return [String]
  #
  # @example
  #   123400000.to_money => "NT$1,234.00"
  #   123400000.to_money('twd') => "NT$1,234.00"

  def to_money(money_type = 'twd')
    currency = Money::Currency.new money_type
    amount = self.to_f * currency.subunit_to_unit / MONEY_I2F
    Money.new(amount, money_type).format(disambiguate: true)
  end


  # Convert money from big integer value to round currency value.
  #
  # @param [String] money_type
  #
  # @return [String]
  #
  # @example
  #   123426000.to_round_money('twd') => "NT$1,234"
  #   123456000.to_round_money('twd') => "NT$1,235"

  def to_round_money(money_type = 'twd')
    currency = Money::Currency.new money_type
    amount = self.to_f * currency.subunit_to_unit / MONEY_I2F
    amount = (amount/currency.subunit_to_unit).round * currency.subunit_to_unit
    Money.new(amount, money_type).format(disambiguate: true, no_cents: true)
  end


  # Convert money from big integer value to ceil currency value.
  #
  # @param [String] money_type
  #
  # @return [String]
  #
  # @example
  #   123426000.to_ceil_money('twd') => "NT$1,235.00"
  #   123476000.to_ceil_money('twd') => "NT$1,235.00"

  def to_ceil_money(money_type = 'twd')
    currency = Money::Currency.new money_type
    amount = self.to_f * currency.subunit_to_unit / MONEY_I2F
    amount = (amount/currency.subunit_to_unit).ceil * currency.subunit_to_unit
    Money.new(amount, money_type).format(disambiguate: true)
  end


  # Convert money from big integer value to float value.
  #
  # @param [String] money_type
  #
  # @return [Float]
  #
  # @example
  #   123426000.pure_money('twd') => 1234.26
  #   123456000.pure_money('twd') => 1234.56

  def pure_money(money_type = 'twd')
    self.to_f / MONEY_I2F
  end


  # Convert money from big integer value to round integer value.
  #
  # @param [String] money_type
  #
  # @return [Integer]
  #
  # @example
  #   123426000.pure_round_money('twd') => 1234
  #   123456000.pure_round_money('twd') => 1235

  def pure_round_money(money_type = 'twd')
    (self.to_f / MONEY_I2F).round
  end


  # The floor value (big integer) of big integer money value.
  #
  # @param [String] money_type
  #
  # @return [Integer]
  #
  # @example
  #   (123426345).raw_floor_money('twd') => 1234260000
  #   (123426845).raw_floor_money('twd') => 1234260000

  def raw_floor_money(money_type = 'twd')
    (self.to_f / MONEY_DELTA).floor * MONEY_DELTA
  end


  # The ceil value (big integer) of big integer money value.
  #
  # @param [String] money_type
  #
  # @return [Integer]
  #
  # @example
  #   (123426345).raw_ceil_money('twd') => 1234270000
  #   (123426845).raw_ceil_money('twd') => 1234270000

  def raw_ceil_money(money_type = 'twd')
    (self.to_f / MONEY_DELTA).ceil * MONEY_DELTA
  end


  # The fee (big integer) of big integer money value.
  #
  # @param [Float] rate
  # @param [String] money_type
  #
  # @return [Integer]
  #
  # @example
  #   (100_00000).raw_money_for_fee(0.3, 'twd') => 30_00000
  #   (100_00000).raw_money_for_fee(0, 'twd') => 0

  def raw_money_for_fee(rate, money_type = 'twd')
    ((self.to_f * rate / MONEY_DELTA).ceil) * MONEY_DELTA
  end


  # The big integer value of float money.
  # It accepts a Float number as receiver.
  #
  # @param [String] money_type
  #
  # @return [Integer]
  #
  # @example
  #   (1234.26).f2i_money('twd') => 123426000

  def f2i_money(money_type = 'twd')
    (self * MONEY_I2F).round
  end

end
