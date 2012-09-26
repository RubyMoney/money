class Money
  module Arithmetic

    # Returns a money object with changed polarity.
    #
    # @return [Money]
    #
    # @example
    #    - Money.new(100) #=> #<Money @fractional=-100>
    def -@
      Money.new(-fractional, currency)
    end


    # Checks whether two money objects have the same currency and the same
    # amount. Checks against money objects with a different currency and checks
    # against objects that do not respond to #to_money will always return false.
    #
    # @param [Money] other_money Value to compare with.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(100) == Money.new(101) #=> false
    #   Money.new(100) == Money.new(100) #=> true
    def ==(other_money)
      if other_money.respond_to?(:to_money)
        other_money = other_money.to_money
        fractional == other_money.fractional && self.currency == other_money.currency
      else
        false
      end
    end

    # Synonymous with +#==+.
    #
    # @param [Money] other_money Value to compare with.
    #
    # @return [Money]
    #
    # @see #==
    def eql?(other_money)
      self == other_money
    end

    def <=>(other_money)
      if other_money.respond_to?(:to_money)
        other_money = other_money.to_money
        if self.currency == other_money.currency
          fractional <=> other_money.fractional
        else
          fractional <=> other_money.exchange_to(currency).fractional
        end
      else
        raise ArgumentError, "Comparison of #{self.class} with #{other_money.inspect} failed"
      end
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
      fractional > 0
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
      fractional < 0
    end

    # Returns a new Money object containing the sum of the two operands' monetary
    # values. If +other_money+ has a different currency then its monetary value
    # is automatically exchanged to this object's currency using +exchange_to+.
    #
    # @param [Money] other_money Other +Money+ object to add.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100) + Money.new(100) #=> #<Money @fractional=200>
    def +(other_money)
      if currency == other_money.currency
        Money.new(fractional + other_money.fractional, other_money.currency)
      else
        Money.new(fractional + other_money.exchange_to(currency).fractional, currency)
      end
    end

    # Returns a new Money object containing the difference between the two
    # operands' monetary values. If +other_money+ has a different currency then
    # its monetary value is automatically exchanged to this object's currency
    # using +exchange_to+.
    #
    # @param [Money] other_money Other +Money+ object to subtract.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100) - Money.new(99) #=> #<Money @fractional=1>
    def -(other_money)
      if currency == other_money.currency
        Money.new(fractional - other_money.fractional, other_money.currency)
      else
        Money.new(fractional - other_money.exchange_to(currency).fractional, currency)
      end
    end

    # Multiplies the monetary value with the given number and returns a new
    # +Money+ object with this monetary value and the same currency.
    #
    # Note that you can't multiply a Money object by an other +Money+ object.
    #
    # @param [Numeric] value Number to multiply by.
    #
    # @return [Money] The resulting money.
    #
    # @raise [ArgumentError] If +value+ is a Money instance.
    #
    # @example
    #   Money.new(100) * 2 #=> #<Money @fractional=200>
    #
    def *(value)
      if value.is_a?(Money)
        raise ArgumentError, "Can't multiply a Money by a Money"
      else
        Money.new(fractional * value, currency)
      end
    end

    # Divides the monetary value with the given number and returns a new +Money+
    # object with this monetary value and the same currency.
    # Can also divide by another +Money+ object to get a ratio.
    #
    # +Money/Numeric+ returns +Money+. +Money/Money+ returns +Float+.
    #
    # @param [Money, Numeric] value Number to divide by.
    #
    # @return [Money] The resulting money if you divide Money by a number.
    # @return [Float] The resulting number if you divide Money by a Money.
    #
    # @example
    #   Money.new(100) / 10            #=> #<Money @fractional=10>
    #   Money.new(100) / Money.new(10) #=> 10.0
    #
    def /(value)
      if value.is_a?(Money)
        if currency == value.currency
          (fractional / BigDecimal.new(value.fractional.to_s)).to_f
        else
          (fractional / BigDecimal(value.exchange_to(currency).fractional.to_s)).to_f
        end
      else
        Money.new(fractional / value, currency)
      end
    end

    # Synonym for +#/+.
    #
    # @param [Money, Numeric] value Number to divide by.
    #
    # @return [Money] The resulting money if you divide Money by a number.
    # @return [Float] The resulting number if you divide Money by a Money.
    #
    # @see #/
    #
    def div(value)
      self / value
    end

    # Divide money by money or fixnum and return array containing quotient and
    # modulus.
    #
    # @param [Money, Fixnum] val Number to divmod by.
    #
    # @return [Array<Money,Money>,Array<Fixnum,Money>]
    #
    # @example
    #   Money.new(100).divmod(9)            #=> [#<Money @fractional=11>, #<Money @fractional=1>]
    #   Money.new(100).divmod(Money.new(9)) #=> [11, #<Money @fractional=1>]
    def divmod(val)
      if val.is_a?(Money)
        a = self.fractional
        b = self.currency == val.currency ? val.fractional : val.exchange_to(self.currency).cents
        q, m = a.divmod(b)
        return [q, Money.new(m, self.currency)]
      else
        if self.class.infinite_precision
          q, m = self.fractional.divmod(BigDecimal(val.to_s))
          return [Money.new(q, self.currency), Money.new(m, self.currency)]
        else
          return [self.div(val), Money.new(self.fractional.modulo(val), self.currency)]
        end
      end
    end

    # Equivalent to +self.divmod(val)[1]+
    #
    # @param [Money, Fixnum] val Number take modulo with.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100).modulo(9)            #=> #<Money @fractional=1>
    #   Money.new(100).modulo(Money.new(9)) #=> #<Money @fractional=1>
    def modulo(val)
      self.divmod(val)[1]
    end

    # Synonym for +#modulo+.
    #
    # @param [Money, Fixnum] val Number take modulo with.
    #
    # @return [Money]
    #
    # @see #modulo
    def %(val)
      self.modulo(val)
    end

    # If different signs +self.modulo(val) - val+ otherwise +self.modulo(val)+
    #
    # @param [Money, Fixnum] val Number to rake remainder with.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(100).remainder(9) #=> #<Money @fractional=1>
    def remainder(val)
      a, b = self, val
      b = b.exchange_to(a.currency) if b.is_a?(Money) and a.currency != b.currency

      a_sign, b_sign = :pos, :pos
      a_sign = :neg if a.fractional < 0
      b_sign = :neg if (b.is_a?(Money) and b.fractional < 0) or (b < 0)

      return a.modulo(b) if a_sign == b_sign
      a.modulo(b) - (b.is_a?(Money) ? b : Money.new(b, a.currency))
    end

    # Return absolute value of self as a new Money object.
    #
    # @return [Money]
    #
    # @example
    #   Money.new(-100).abs #=> #<Money @fractional=100>
    def abs
      Money.new(self.fractional.abs, self.currency)
    end

    # Test if the money amount is zero.
    #
    # @return [Boolean]
    #
    # @example
    #   Money.new(100).zero? #=> false
    #   Money.new(0).zero?   #=> true
    def zero?
      fractional == 0
    end

    # Test if the money amount is non-zero. Returns this money object if it is
    # non-zero, or nil otherwise, like +Numeric#nonzero?+.
    #
    # @return [Money, nil]
    #
    # @example
    #   Money.new(100).nonzero? #=> #<Money @fractional=100>
    #   Money.new(0).nonzero?   #=> nil
    def nonzero?
      fractional != 0 ? self : nil
    end

  end
end
