# encoding: utf-8

class Money
  class Custom
    class << self

      def exponent(currency='btc')
        @@h_exp ||= {}
        @@h_exp[currency] ||= Money::Currency.new(currency).exponent
      end

    end
  end
end
