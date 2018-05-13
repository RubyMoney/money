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
    def initialize(amount, parts, whole_amounts = true)
      @amount = amount
      @parts = parse_parts(parts)
      @whole_amounts = whole_amounts

      raise ArgumentError, 'need at least one party' if @parts.empty?
    end

    def generate
      result = []
      remaining_amount = amount
      remaining_parts = parts.reverse

      while !remaining_parts.empty? do
        parts_sum = remaining_parts.inject(0, :+)
        part = remaining_parts.shift

        current_split = remaining_amount * part / parts_sum
        current_split = current_split.truncate if whole_amounts

        result << current_split
        remaining_amount -= current_split
      end

      result.reverse
    end

    private

    attr_reader :amount, :parts, :whole_amounts

    def parse_parts(parts_or_number)
      if parts_or_number.is_a?(Numeric)
        Array.new(parts_or_number, 1)
      else
        parts_or_number
      end
    end
  end
end
