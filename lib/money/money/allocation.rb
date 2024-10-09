# encoding: utf-8

class Money
  class Allocation
    # Allocates a specified amount into parts based on their proportions or distributes
    # it evenly when the number of parts is specified numerically.
    #
    # The total of the allocated amounts will always equal the original amount.
    #
    # The parts can be specified as:
    #   Numeric — performs the split between a given number of parties evenly
    #   Array<Numeric> — allocates the amounts proportionally to the given array
    #
    # @param amount [Numeric] The total amount to be allocated.
    # @param parts [Numeric, Array<Numeric>] Number of parts to split into or an array (proportions for allocation)
    # @param rounding_mode [Boolean, Integer] Specifies the rounding mode. If true, rounds to whole amounts.
    #   If an integer, rounds to that decimal precision. Defaults to true (whole amounts).
    #
    # @return [Array<Numeric>] An array containing the allocated amounts.
    # @raise [ArgumentError] If parts is empty or not provided.
    def self.generate(amount, parts, rounding_mode = true)
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
      round_to_whole = rounding_mode.is_a?(TrueClass)
      round_to_precision = rounding_mode.is_a?(Integer)

      until parts.empty? do
        parts_sum = parts.inject(0, :+)
        part = parts.pop

        current_split = 0
        if parts_sum > 0
          current_split = remaining_amount * part / parts_sum
          current_split =
            if round_to_whole
              current_split.truncate
            elsif round_to_precision
              current_split.round(rounding_mode)
            else
              current_split
            end
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
