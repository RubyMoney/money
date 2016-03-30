class Money
  module Allocate
    # Allocates money between different parties without losing pennies.
    # After the mathematical split has been performed, leftover pennies will
    # be distributed round-robin amongst the parties. This means that parties
    # listed first will likely receive more pennies than ones that are listed later
    #
    # @param [Array<Numeric>] splits [0.50, 0.25, 0.25] to give 50% of the cash to party1, 25% to party2, and 25% to party3.
    #
    # @return [Array<Money>]
    #
    # @example
    #   Money.new(5,   "USD").allocate([0.3, 0.7])         #=> [Money.new(2), Money.new(3)]
    #   Money.new(100, "USD").allocate([0.33, 0.33, 0.33]) #=> [Money.new(34), Money.new(33), Money.new(33)]
    #
    def allocate(splits)
      allocations = splits.inject(0.to_d) { |sum, n| sum + n }

      if (allocations - 1) > Float::EPSILON
        raise ArgumentError, "splits add to more then 100%"
      end

      amounts, left_over = amounts_from_splits(allocations, splits)

      unless self.class.infinite_precision
        left_over.to_i.times { |i| amounts[i % amounts.length] += 1 }
      end

      subunit_to_unit = currency.subunit_to_unit
      amounts.collect { |x| build_new(x.to_d / subunit_to_unit, currency) }
    end

    # Split money amongst parties evenly without losing pennies.
    #
    # @param [Numeric] num number of parties.
    #
    # @return [Array<Money>]
    #
    # @example
    #   Money.new(100, "USD").split(3) #=> [Money.new(34), Money.new(33), Money.new(33)]
    def split(num)
      raise ArgumentError, "need at least one party" if num < 1

      if self.class.infinite_precision
        split_infinite(num)
      else
        split_flat(num)
      end
    end

    private

    def amounts_from_splits(allocations, splits)
      fractional = self.fractional
      left_over = fractional

      amounts = splits.map do |ratio|
        if self.class.infinite_precision
          fractional * ratio
        else
          (fractional * ratio / allocations).floor.tap do |frac|
            left_over -= frac
          end
        end
      end

      [amounts, left_over]
    end

    def split_infinite(num)
      part = div(num)
      Array.new(num) { part }
    end

    def split_flat(num)
      subunit_to_unit = currency.subunit_to_unit
      fractional = self.fractional
      low = build_new((fractional / num).to_d / subunit_to_unit, currency)
      high = build_new(low.to_d + 1.to_d / subunit_to_unit, currency)
      remainder = fractional % num
      Array.new(num) { |index| index < remainder ? high : low }
    end
  end
end
