# Open +Symbol+ to add new methods.
class Symbol
  # Converts the current symbol into a +Currency+ object.
  #
  # @return [Money::Currency]
  #
  # @raise [Money::Currency::UnknownCurrency]
  #   If this String reference an unknown currency.
  #
  # @example
  #   :ars.to_currency #=> #<Money::Currency id: ars>
  #
  def to_currency
    unless Money.silence_core_extensions_deprecations
      Money.deprecate "as of Money 6.1.0 you must `require 'money/core_extensions'` to use Symbol#to_currency."
    end
    Money::Currency.new(self)
  end
end
