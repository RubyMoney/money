class Money
  module V6Compatibility
    module_function

    def arithmetic
      Money.prepend Arithmetic
    end

    module Arithmetic
      # Wrapper for coerced numeric values to distinguish
      # when numeric was on the 1st place in operation.
      CoercedNumeric = Struct.new(:value) do
        # Proxy #zero? method to skip unnecessary typecasts. See #- and #+.
        def zero?
          value.zero?
        end
      end

      def coerce(value)
        [self, CoercedNumeric.new(value)]
      end

      def <=>(other)
        if !other.is_a?(Money) && other.respond_to?(:zero?) && other.zero?
          return other.is_a?(CoercedNumeric) ? 0 <=> fractional : fractional <=> 0
        end
        super
      end

      # Uses Comparable's implementation but raises ArgumentError if non-zero
      # numeric value is given.
      def ==(other)
        if other.is_a?(Numeric) && !other.zero?
          raise ArgumentError, 'Money#== supports only zero numerics'
        end
        super
      end

      def +(other)
        return self if !other.is_a?(Money) && other.zero?
        super
      end

      def -(other)
        return self if !other.is_a?(Money) && other.zero?
        super
      end

      def *(other)
        other = other.value if other.is_a?(CoercedNumeric)
        super
      end

      def /(other)
        raise TypeError, 'Can not divide by Money' if other.is_a?(CoercedNumeric)
        super
      end
      alias_method :div, :/
    end
  end
end
