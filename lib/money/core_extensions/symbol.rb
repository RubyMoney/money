class Symbol
  alias_method :_to_currency, :to_currency
  def to_currency(*args)
    Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use Symbol#to_currency. Please start using the Monetize gem from https://github.com/RubyMoney/monetize if you are not already doing so"
    _to_currency(*args)
  end
end
