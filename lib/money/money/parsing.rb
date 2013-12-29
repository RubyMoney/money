#encoding: utf-8

class Money
  module Parsing
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parse(input, currency = nil)
        Money.deprecate ".parse is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.parse(input, currency)
      end

      def from_string(value, currency = Money.default_currency)
        Money.deprecate ".from_string is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.from_string(value, currency)
      end

      def from_fixnum(value, currency = Money.default_currency)
        Money.deprecate ".from_fixnum is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.from_fixnum(value, currency)
      end

      def from_float(value, currency = Money.default_currency)
        Money.deprecate ".from_float is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.from_float(value, currency)
      end

      def from_bigdecimal(value, currency = Money.default_currency)
        Money.deprecate ".from_bigdecimal is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.from_bigdecimal(value, currency)
      end

      def from_numeric(value, currency = Money.default_currency)
        Money.deprecate ".from_numeric is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.from_numeric(value, currency)
      end

      def extract_cents(input, currency = Money.default_currency)
        Money.deprecate ".extract_cents is deprecated and will be removed in 6.1.0. Please use the `monetize` gem."
        Monetize.extract_cents(input, currency)
      end
    end
  end
end
