class Money
  module V6Compatibility
    module_function

    def fractional
      Money.prepend Fractional
      Money.extend Fractional::ClassMethods
    end

    module Fractional
      module ClassMethods
        def from_amount(amount, currency = nil, bank = nil)
          Numeric === amount or raise ArgumentError, "'amount' must be numeric"
          new(amount, currency, bank, true)
        end

        def from_subunits(amount, currency = nil, bank = nil)
          raise 'Use .new'
        end

        def new(val, currency = nil, bank = nil, from_amount = false)
          return super(val, currency, bank) if val.is_a?(self) || from_amount
          currency = Currency.wrap(currency || default_currency)
          amount = as_d(val) / currency.subunit_to_unit
          super(amount, currency, bank)
        end

        def as_d(value)
          if value.respond_to?(:to_d)
            value.is_a?(Rational) ? value.to_d(conversion_precision) : value.to_d
          else
            BigDecimal.new(value.to_s)
          end
        end
      end

      def to_f
        amount.to_f
      end

      def yaml_initialize(_tag, attrs)
        super
        fractional = attrs['fractional']
        @amount = as_d(fractional) / currency.subunit_to_unit if fractional
      end

      def round_to_nearest_cash_value
        value = super * currency.subunit_to_unit
        self.class.infinite_precision ? value : value.to_i
      end

      def %(other)
        other = other.to_d / currency.subunit_to_unit unless other.is_a?(Money)
        super
      end
      alias_method :modulo, :%

      def remainder(other)
        other = other.to_d / currency.subunit_to_unit unless other.is_a?(Money)
        super
      end

      private

      def build_new(amount, currency = self.currency, bank = self.bank)
        self.class.new(amount, currency, bank, true)
      end

      def as_d(num)
        self.class.as_d(num)
      end
    end
  end
end
