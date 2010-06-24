# encoding: utf-8

class Money

  class DeprecatedHash < Hash

    def initialize(hash, message)
      @message = message
      replace(hash)
    end

    def [](key)
      deprecate
      super
    end

    def []=(value)
      deprecate
      super
    end

    private

      def deprecate
        warn "DEPRECATION MESSAGE: #{@message}"
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
    # Everything else defaults to '$'
  }, "Money::SYMBOLS has no longer effect. See Money::Currency#symbol.")

  SEPARATORS = DeprecatedHash.new({
    "BRL" => ",",
    # Everything else defaults to '.'
  }, "Money::SEPARATORS is deprecated. See Money::Currency#separator.")

  DELIMITERS = {
    "BRL" => ".",
    # Everything else defaults to ","
  }

end
