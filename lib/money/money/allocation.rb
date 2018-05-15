# encoding: utf-8

class Money
  class Allocation
    # Splits a given amount in parts without loosing pennies.
    # The left-over pennies will be distributed round-robin amongst the parties. This means that
    # parties listed first will likely receive more pennies than ones that are listed later.
    #
    # The results should always add up to the original amount.
    #
    # The parts can be specified as:
    #   Numeric — performs the split between a given number of parties evenely
    #   Array<Numeric> — allocates the amounts proportionally to the given array
    #
    def self.generate(amount, parts, whole_amounts = true)
      parts = parts.is_a?(Numeric) ? Array.new(parts, 1) : parts.dup

      raise ArgumentError, 'need at least one party' if parts.empty?

      result = []
      remaining_amount = amount

      until parts.empty? do
        parts_sum = parts.inject(0, :+)
        part = parts.pop

        current_split = remaining_amount * part / parts_sum
        current_split = current_split.truncate if whole_amounts

        result.unshift current_split
        remaining_amount -= current_split
      end

      result
    end
  end
end
