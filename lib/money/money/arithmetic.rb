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
        Money.deprecate "as of Money 6.1.0 you must `require 'money/core_extension'` to compare Money to core classes." unless other_money.is_a? Money
        other_money = other_money.to_money
        fractional == other_money.fractional && currency == other_money.currency
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
        Money.deprecate "as of Money 6.1.0 you must `require 'money/core_extension'` to compare Money to core classes." unless other_money.is_a? Money
        other_money = other_money.to_money
        if fractional == 0 || other_money.fractional == 0 || currency == other_money.currency
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
      other_money = other_money.exchange_to(currency)
      Money.new(fractional + other_money.fractional, currency)
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
      other_money = other_money.exchange_to(currency)
      Money.new(fractional - other_money.fractional, currency)
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
    # @raise [ArgumentError] If +value+ is NOT a number.
    #
    # @example
    #   Money.new(100) * 2 #=> #<Money @fractional=200>
    #
    def *(value)
      if value.is_a? Numeric
        Money.new(fractional * value, currency)
      else
        raise ArgumentError, "Can't multiply a Money by a #{value.class.name}'s value"
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
        fractional / as_d(value.exchange_to(currency).fractional).to_f
      else
        Money.new(fractional / as_d(value), currency)
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
        a = fractional
        b = val.exchange_to(currency).cents
        q, m = a.divmod(b)
        return [q, Money.new(m, currency)]
      else
        if self.class.infinite_precision
          q, m = fractional.divmod(as_d(val))
          return [Money.new(q, currency), Money.new(m, currency)]
        else
          return [div(val), Money.new(fractional.modulo(val), currency)]
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
      divmod(val)[1]
    end

    # Synonym for +#modulo+.
    #
    # @param [Money, Fixnum] val Number take modulo with.
    #
    # @return [Money]
    #
    # @see #modulo
    def %(val)
      modulo(val)
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
      Money.new(fractional.abs, currency)
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

    # Used to make Money instance handle the operations when arguments order is reversed
    # @return [Array]
    #
    # @example
    #   2 * Money.new(10) #=> #<Money @fractional=20>
    def coerce(other)
      [self, other]
    end
  end
end
