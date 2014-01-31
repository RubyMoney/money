#encoding: utf-8

class Money
  module Parsing
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parse(input, currency = nil)
        Monetize.parse(input, currency)
      end

      def from_string(value, currency = Money.default_currency)
        Monetize.from_string(value, currency)
      end

      def from_fixnum(value, currency = Money.default_currency)
        Monetize.from_fixnum(value, currency)
      end

      def from_float(value, currency = Money.default_currency)
        Monetize.from_float(value, currency)
      end

      def from_bigdecimal(value, currency = Money.default_currency)
        Monetize.from_bigdecimal(value, currency)
      end

      def from_numeric(value, currency = Money.default_currency)
        Monetize.from_numeric(value, currency)
      end

      def extract_cents(input, currency = Money.default_currency)
        Monetize.extract_cents(input, currency)
      end
    end
  end
end
