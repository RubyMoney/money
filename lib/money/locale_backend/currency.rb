require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class Currency < Base
      def lookup(key, currency)
        currency.public_send(key) if currency.respond_to?(key)
      end
    end
  end
end
