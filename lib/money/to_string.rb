class Money
  module ToString
    # Returns the amount of money as a string.
    #
    # @return [String]
    #
    # @example
    #   Money.ca_dollar(100).to_s #=> "1.00"
    def to_s
      unit, subunit, fraction = strings_from_fractional

      str = if currency.decimal_places == 0
              if fraction == ""
                unit
              else
                "#{unit}#{decimal_mark}#{fraction}"
              end
            else
              "#{unit}#{decimal_mark}#{pad_subunit(subunit)}#{fraction}"
            end

      fractional < 0 ? "-#{str}" : str
    end

    def decimal_mark
      self.class.formatter.new(self).decimal_mark
    end

    private

    def strings_from_fractional
      unit, subunit = fractional().abs.divmod(currency.subunit_to_unit)

      if self.class.infinite_precision
        strings_for_infinite_precision(unit, subunit)
      else
        strings_for_base_precision(unit, subunit)
      end
    end

    def strings_for_infinite_precision(unit, subunit)
      subunit, fraction = subunit.divmod(BigDecimal("1"))
      fraction = fraction.to_s("F")[2..-1] # want fractional part "0.xxx"
      fraction = "" if fraction =~ /^0+$/

      [unit.to_i.to_s, subunit.to_i.to_s, fraction]
    end

    def strings_for_base_precision(unit, subunit)
      [unit.to_s, subunit.to_s, ""]
    end

    def pad_subunit(subunit)
      cnt = currency.decimal_places
      padding = "0" * cnt
      "#{padding}#{subunit}"[-1 * cnt, cnt]
    end
  end
end
