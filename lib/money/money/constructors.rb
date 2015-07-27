class Money
  module Constructors

    # Create a new money object with value 0.
    #
    # @param [Currency, String, Symbol] currency The currency to use.
    #
    # @return [Money]
    #
    # @example
    #   Money.empty #=> #<Money @fractional=0>
    def empty(currency = default_currency)
      @empty ||= {}
      @empty[currency] ||= new(0, currency).freeze
    end
    alias_method :zero, :empty


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
end
