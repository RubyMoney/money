class String
  alias_method :_to_money, :to_money
  def to_money(*args)
    Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use String#to_money."
    _to_money(*args)
  end

  alias_method :_to_currency, :to_currency
  def to_currency(*args)
    unless Money.silence_core_extensions_deprecations
      Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use String#to_currency."
    end
    _to_currency(*args)
  end
end
