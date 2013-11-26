# Open +String+ to add new methods.
class String
  # Parses the current string and converts it to a +Money+ object.
  # Excess characters will be discarded.
  #
  # @param [Currency, String, Symbol] currency
  #   The currency to set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @example
  #   '100'.to_money                #=> #<Money @fractional=10000>
  #   '100.37'.to_money             #=> #<Money @fractional=10037>
  #   '100 USD'.to_money            #=> #<Money @fractional=10000, @currency=#<Money::Currency id: usd>>
  #   'USD 100'.to_money            #=> #<Money @fractional=10000, @currency=#<Money::Currency id: usd>>
  #   '$100 USD'.to_money           #=> #<Money @fractional=10000, @currency=#<Money::Currency id: usd>>
  #   'hello 2000 world'.to_money   #=> #<Money @fractional=200000 @currency=#<Money::Currency id: usd>>
  #
  # @see Money.from_string
  #
  def to_money(currency = nil)
    Money.deprecate "String#to_money is deprecated and will be removed in 6.1.0. Please write your own parsing methods."
    Money.parse(self, currency)
  end

  # Converts the current string into a +Currency+ object.
  #
  # @return [Money::Currency]
  #
  # @raise [Money::Currency::UnknownCurrency]
  #   If this String reference an unknown currency.
  #
  # @example
  #   "USD".to_currency #=> #<Money::Currency id: usd>
  #
  def to_currency
    unless Money.silence_core_extensions_deprecations
      Money.deprecate "as of Money 6.1.0 you must `require 'money/core_extensions'` to use String#to_currency."
    end
    Money::Currency.new(self)
  end
end
