# encoding: utf-8

class Money

  class DeprecatedHash < Hash

    def initialize(hash, message)
      @message = message
      replace(hash)
    end

    def [](key)
      Money.deprecate(@message)
      super
    end

    def []=(value)
      Money.deprecate(@message)
      super
    end

  end

  # @deprecated See Money::Currency#symbol
  SYMBOLS = DeprecatedHash.new({
    "GBP" => "£",
    "JPY" => "¥",
    "EUR" => "€",
    "ZWD" => "Z$",
    "CNY" => "¥",
    "INR" => "₨",
    "NPR" => "₨",
    "SCR" => "₨",
    "LKR" => "₨",
    "SEK" => "kr",
    "GHC" => "¢",
    "BRL" => "R$ ",
    # Everything else defaults to '¤'
  }, "Money::SYMBOLS has no longer effect and will be removed in v3.2.0. See Money::Currency#symbol.")

  SEPARATORS = DeprecatedHash.new({
    "BRL" => ",",
    # Everything else defaults to '.'
  }, "Money::SEPARATORS is deprecated and will be removed in v3.2.0. See Money::Currency#separator.")

  DELIMITERS = DeprecatedHash.new({
    "BRL" => ".",
    # Everything else defaults to ","
  }, "Money::DELIMITERS is deprecated and will be removed in Money v3.2.0. See Money::Currency#delimiter.")

end
