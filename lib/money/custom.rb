# encoding: utf-8

class Money
  class Custom
    class << self

      # returns the number of significant decimal places needed
      #   in a currency, ie. 
      #     $1.00USD => 2.0
      #     1.00000000BTC => 8.0
      def exponent(currency='btc')
        @@h_exp ||= {}
        @@h_exp[currency] ||= Money::Currency.new(currency).exponent
      end

    end
  end
end
