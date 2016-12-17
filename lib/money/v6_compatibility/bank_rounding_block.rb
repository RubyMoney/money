class Money
  module V6Compatibility
    module_function

    def bank_rounding_block
      Bank::VariableExchange.prepend BankRoundingBlock
    end

    module BankRoundingBlock
      def exchange_with(from, to_currency, &block)
        to_currency = Currency.wrap(to_currency)
        if from.currency == to_currency
          from
        else
          rate = get_rate(from.currency, to_currency)
          unless rate
            raise Bank::UnknownRate, "No conversion rate known for " \
              "'#{from.currency.code}' -> '#{to_currency}'"
          end
          new_fractional = exchange(from.fractional, rate, &block).to_d
          from.send(:build_new, new_fractional / to_currency.subunit_to_unit, to_currency)
        end
      end

      def exchange(value, rate, &block)
        rate = BigDecimal.new(rate.to_s) unless rate.is_a?(BigDecimal)
        ex = rate * value
        if block_given?
          yield ex
        elsif rounding_method
          rounding_method.call(ex)
        else
          ex
        end
      end
    end
  end
end
