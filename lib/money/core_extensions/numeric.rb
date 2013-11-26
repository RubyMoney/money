# Open +Numeric+ to add new method.
class Numeric
  # Converts this numeric into a +Money+ object in the given +currency+.
  #
  # @param [Currency, String, Symbol] currency
  #   The currency to set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @example
  #   100.to_money                   #=> #<Money @fractional=10000>
  #   100.37.to_money                #=> #<Money @fractional=10037>
  #   BigDecimal.new('100').to_money #=> #<Money @fractional=10000>
  #
  # @see Money.from_numeric
  #
  def to_money(currency = nil)
    unless Money.silence_core_extensions_deprecations
      Money.deprecate "as of Money 6.1.0 you must `require 'money/core_extensions'` to use Numeric#to_money."
    end
    Money.from_numeric(self, currency || Money.default_currency)
  end
end
