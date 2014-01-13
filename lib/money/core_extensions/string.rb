class String
  alias_method :_to_money, :to_money
  def to_money(*args)
    Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use String#to_money. Please start using the Monetize gem from https://github.com/RubyMoney/monetize if you are not already doing so"
    _to_money(*args)
  end

  alias_method :_to_currency, :to_currency
  def to_currency(*args)
    Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use String#to_currency. Please start using the Monetize gem from https://github.com/RubyMoney/monetize if you are not already doing so"
    _to_currency(*args)
  end
end
