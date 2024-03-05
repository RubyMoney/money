# encoding: utf-8

class Money
  class Allocation
    # Splits a given amount in parts. The allocation is based on the parts' proportions
    # or evenly if parts are numerically specified.
    #
    # The results should always add up to the original amount.
    #
    # @param amount [Numeric] The total amount to be allocated.
    # @param parts [Numeric, Array<Numeric>] Number of parts to split into or an array (proportions for allocation)
    # @param whole_amounts [Boolean] Specifies whether to allocate whole amounts only. Defaults to true.
    #
    # @return [Array<Numeric>] An array containing the allocated amounts.
    # @raise [ArgumentError] If parts is empty or not provided.
    def self.generate(amount, parts, whole_amounts = true)
      parts = if parts.is_a?(Numeric)
        Array.new(parts, 1)
      elsif parts.all?(&:zero?)
        Array.new(parts.count, 1)
      else
        parts.dup
      end

      raise ArgumentError, 'need at least one part' if parts.empty?

      if [amount, *parts].any? { |i| i.is_a?(BigDecimal) || i.is_a?(Float) || i.is_a?(Rational) }
        amount = convert_to_big_decimal(amount)
        parts.map! { |p| convert_to_big_decimal(p) }
      end

      result = []
      remaining_amount = amount

      until parts.empty? do
        parts_sum = parts.inject(0, :+)
        part = parts.pop

        current_split = 0
        if parts_sum > 0
          current_split = remaining_amount * part / parts_sum
          current_split = current_split.truncate if whole_amounts
        end

        result.unshift current_split
        remaining_amount -= current_split
      end

      result
    end

    # Converts a given number to BigDecimal.
    # This method supports inputs of BigDecimal, Rational, and other numeric types by ensuring they are all returned
    # as BigDecimal instances for consistent handling.
    #
    # @param number [Numeric, BigDecimal, Rational] The number to convert.
    # @return [BigDecimal] The converted number as a BigDecimal.
    def self.convert_to_big_decimal(number)
      if number.is_a? BigDecimal
        number
      elsif number.is_a? Rational
        BigDecimal(number.to_f.to_s)
      else
        BigDecimal(number.to_s)
      end
    end
  end
end
