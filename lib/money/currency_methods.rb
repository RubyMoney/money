class Money
  module CurrencyMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Creates a new Money object of the given value, using the Canadian
      # dollar currency.
      #
      # @param [Integer] cents The cents value.
      #
      # @return [Money]
      #
      # @example
      #   n = Money.ca_dollar(100)
      #   n.cents    #=> 100
      #   n.currency #=> #<Money::Currency id: cad>
      def ca_dollar(cents)
        new(cents, "CAD")
      end
      alias_method :cad, :ca_dollar


      # Creates a new Money object of the given value, using the American dollar
      # currency.
      #
      # @param [Integer] cents The cents value.
      #
      # @return [Money]
      #
      # @example
      #   n = Money.us_dollar(100)
      #   n.cents    #=> 100
      #   n.currency #=> #<Money::Currency id: usd>
      def us_dollar(cents)
        new(cents, "USD")
      end
      alias_method :usd, :us_dollar


      # Creates a new Money object of the given value, using the Euro currency.
      #
      # @param [Integer] cents The cents value.
      #
      # @return [Money]
      #
      # @example
      #   n = Money.euro(100)
      #   n.cents    #=> 100
      #   n.currency #=> #<Money::Currency id: eur>
      def euro(cents)
        new(cents, "EUR")
      end
      alias_method :eur, :euro


      # Creates a new Money object of the given value, in British pounds.
      #
      # @param [Integer] pence The pence value.
      #
      # @return [Money]
      #
      # @example
      #   n = Money.pound_sterling(100)
      #   n.fractional    #=> 100
      #   n.currency #=> #<Money::Currency id: gbp>
      def pound_sterling(pence)
        new(pence, "GBP")
      end
      alias_method :gbp, :pound_sterling
    end

    # Assuming using a currency using dollars:
    # Returns the value of the money in dollars,
    # instead of in the fractional unit cents.
    #
    # Synonym of #amount
    #
    # @return [BigDecimal]
    #
    # @example
    #   Money.new(1_00, "USD").dollars   # => BigDecimal.new("1.00")
    #
    # @see #amount
    # @see #to_d
    # @see #cents
    #
    def dollars
      amount
    end

    # Convenience method for fractional part of the amount. Synonym of #fractional
    #
    # @return [Integer] when infinite_precision is false
    # @return [BigDecimal] when infinite_precision is true
    #
    # @see infinite_precision
    def cents
      fractional
    end

    # Receive a money object with the same amount as the current Money object
    # in United States dollar.
    #
    # @return [Money]
    #
    # @example
    #   n = Money.new(100, "CAD").as_us_dollar
    #   n.currency #=> #<Money::Currency id: usd>
    def as_us_dollar
      exchange_to("USD")
    end

    # Receive a money object with the same amount as the current Money object
    # in Canadian dollar.
    #
    # @return [Money]
    #
    # @example
    #   n = Money.new(100, "USD").as_ca_dollar
    #   n.currency #=> #<Money::Currency id: cad>
    def as_ca_dollar
      exchange_to("CAD")
    end

    # Receive a money object with the same amount as the current Money object
    # in euro.
    #
    # @return [Money]
    #
    # @example
    #   n = Money.new(100, "USD").as_euro
    #   n.currency #=> #<Money::Currency id: eur>
    def as_euro
      exchange_to("EUR")
    end
  end
end
