class Money
  module Arithmetic
    # Returns a money object with changed polarity.
    #
    # @return [Money]
    #
    # @example
    #    - Money.new(100) #=> #<Money @fractional=-100>
    def -@
      build_new(-to_d, currency)
    end

    # Checks whether two Money objects have the same currency and the same
    # amount. If Money objects have a different currency it will only be true
    # if the amounts are both zero. Checks against objects that are not Money or
    # a subclass will always return false.
    #
    # @param [Money] other Value to compare with.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(100).eql?(Money.new(101))                #=> false
    #   Money.new(100).eql?(Money.new(100))                #=> true
    #   Money.new(100, "USD").eql?(Money.new(100, "GBP"))  #=> false
    #   Money.new(0, "USD").eql?(Money.new(0, "EUR"))      #=> true
    #   Money.new(100).eql?("1.00")                        #=> false
    def eql?(other)
      other.is_a?(Money) && (to_d == other.to_d) &&
        (currency == other.currency || to_d == 0)
    end

    # Compares two Money objects. If money objects have a different currency it
    # will attempt to convert the currency.
    #
    # @param [Money] other Value to compare with.
    #
    # @return [Fixnum]
    #
    # @raise [TypeError] when other object is not Money
    #
    def <=>(other)
      return unless other.is_a?(Money)
      other = other.exchange_to(currency)
      to_d <=> other.to_d
    rescue Money::Bank::UnknownRate
    end

    # Test if the amount is positive. Returns +true+ if the money amount is
    # greater than 0, +false+ otherwise.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(1).positive?  #=> true
    #   Money.new(0).positive?  #=> false
    #   Money.new(-1).positive? #=> false
    def positive?
      to_d > 0
    end

    # Test if the amount is negative. Returns +true+ if the money amount is
    # less than 0, +false+ otherwise.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(-1).negative? #=> true
    #   Money.new(0).negative?  #=> false
    #   Money.new(1).negative?  #=> false
    def negative?
      to_d < 0
    end

    # Returns a new Money object containing the sum of the two operands' monetary
    # values. If +other+ has a different currency then its monetary value
    # is automatically exchanged to this object's currency using +exchange_to+.
    #
    # @param [Money] other Other +Money+ object to add.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100) + Money.new(100) #=> #<Money @amount=200>
    def +(other)
      raise TypeError unless other.is_a?(Money)
      other = other.exchange_to(currency)
      build_new(to_d + other.to_d, currency)
    end

    # Returns a new Money object containing the difference between the two
    # operands' monetary values. If +other+ has a different currency then
    # its monetary value is automatically exchanged to this object's currency
    # using +exchange_to+.
    #
    # @param [Money] other Other +Money+ object to subtract.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100) - Money.new(99) #=> #<Money @amount=1>
    def -(other)
      raise TypeError unless other.is_a?(Money)
      other = other.exchange_to(currency)
      build_new(to_d - other.to_d, currency)
    end

    # Multiplies the monetary value with the given number and returns a new
    # +Money+ object with this monetary value and the same currency.
    #
    # Note that you can't multiply a Money object by an other +Money+ object.
    #
    # @param [Numeric] other Number to multiply by.
    #
    # @return [Money] The resulting money.
    #
    # @raise [TypeError] If +other+ is NOT a number.
    #
    # @example
    #   Money.new(100) * 2 #=> #<Money @amount=200>
    #
    def *(other)
      raise TypeError unless other.is_a?(Numeric)
      build_new(to_d * other, currency)
    end

    # Divides the monetary value with the given number and returns a new +Money+
    # object with this monetary value and the same currency.
    # Can also divide by another +Money+ object to get a ratio.
    #
    # +Money/Numeric+ returns +Money+. +Money/Money+ returns +Float+.
    #
    # @param [Money, Numeric] other Number to divide by.
    #
    # @return [Money] The resulting money if you divide Money by a number.
    # @return [Float] The resulting number if you divide Money by a Money.
    #
    # @example
    #   Money.new(100) / 10            #=> #<Money @amount=10>
    #   Money.new(100) / Money.new(10) #=> 10.0
    #
    def /(other)
      if other.is_a?(Money)
        to_d / other.exchange_to(currency).to_d
      else
        build_new(to_d / other.to_d, currency)
      end
    end
    alias_method :div, :/

    # Divide money by money or fixnum and return array containing quotient and
    # modulus.
    #
    # @param [Money, Fixnum] other Number to divmod by.
    #
    # @return [Array<Money,Money>,Array<Fixnum,Money>]
    #
    # @example
    #   Money.new(100).divmod(9)            #=> [#<Money @amount=11>, #<Money @amount=1>]
    #   Money.new(100).divmod(Money.new(9)) #=> [11, #<Money @amount=1>]
    def divmod(other)
      if other.is_a?(Money)
        delimiter = other.exchange_to(currency).to_d
        quotient, remainder = to_d.divmod(delimiter)
        [quotient, build_new(remainder, currency)]
      else
        subunit_to_unit = currency.subunit_to_unit
        fractional.divmod(other).map { |x| build_new(x.to_d / subunit_to_unit, currency) }
      end
    end

    # Equivalent to +divmod(other)[1]+
    #
    # @param [Money, Fixnum] other Number take modulo with.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100).modulo(9)            #=> #<Money @amount=1>
    #   Money.new(100).modulo(Money.new(9)) #=> #<Money @amount=1>
    def %(other)
      other = other.exchange_to(currency).to_d if other.is_a?(Money)
      build_new(to_d.modulo(other), currency)
    end
    alias_method :modulo, :%

    # If different signs +modulo(other) - other+ otherwise +modulo(other)+
    #
    # @param [Money, Fixnum] other Number to rake remainder with.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100).remainder(9) #=> #<Money @amount=1>
    def remainder(other)
      other = other.exchange_to(currency).to_d if other.is_a?(Money)
      build_new(to_d.remainder(other), currency)
    end

    # Return absolute value of self as a new Money object.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(-100).abs #=> #<Money @amount=100>
    def abs
      to_d >= 0 ? self : build_new(to_d.abs, currency)
    end

    # Test if the money amount is zero.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(100).zero? #=> false
    #   Money.new(0).zero?   #=> true
    def zero?
      to_d == 0
    end

    # Test if the money amount is non-zero. Returns this money object if it is
    # non-zero, or nil otherwise, like +Numeric#nonzero?+.
    #
    # @return [Money, nil]
    #
    # @example
    #   Money.new(100).nonzero? #=> #<Money @amount=100>
    #   Money.new(0).nonzero?   #=> nil
    def nonzero?
      to_d != 0 ? self : nil
    end
  end
end
