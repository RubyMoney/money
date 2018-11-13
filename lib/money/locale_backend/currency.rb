require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class Currency < Base
      def lookup(key, currency)
        if currency.respond_to?(key)
          currency.public_send(key)
        elsif key == :format
          currency.symbol_first? ? '%u%n' : '%n %u'
        end
      end
    end
  end
end
