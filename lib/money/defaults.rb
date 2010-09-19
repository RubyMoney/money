# encoding: utf-8

class Money
  # Used to notify users about the deprecated constants.
  # @see Money::SYMBOLS, Money::SEPARATOR and Money::DELIMITERS
  class DeprecatedHash < Hash

    # Creates a new +DeprecatedHash+ with message that will be displayed when
    # accessing +#[]+ and +#[]=+.
    def initialize(hash, message)
      @message = message
      replace(hash)
    end

    # Displays @message then calls +super+.
    def [](key)
      Money.deprecate(@message)
      super
    end

    # Displays @message then calls +super+.
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

  # @deprecated See Money::Currency#separator
  SEPARATORS = DeprecatedHash.new({
    "BRL" => ",",
    # Everything else defaults to '.'
  }, "Money::SEPARATORS is deprecated and will be removed in v3.2.0. See Money::Currency#separator.")

  # @deprecated See Money::Currency#delimiter
  DELIMITERS = DeprecatedHash.new({
    "BRL" => ".",
    # Everything else defaults to ","
  }, "Money::DELIMITERS is deprecated and will be removed in Money v3.2.0. See Money::Currency#delimiter.")
end
