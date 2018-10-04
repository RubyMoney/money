require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class Legacy < Base
      def lookup(key, currency)
        currency.public_send(key)
      end
    end
  end
end
