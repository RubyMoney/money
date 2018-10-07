require 'money/locale_backend/base'
require 'money/locale_backend/i18n'

class Money
  module LocaleBackend
    class Legacy < Base
      def initialize
        raise NotSupported, 'I18n not found' if Money.use_i18n && !defined?(::I18n)
      end

      def lookup(key, currency)
        warn '[DEPRECATION] You are using the default localization behaviour that will change in the next major release. Find out more - https://github.com/RubyMoney/money#deprecation'

        if Money.use_i18n
          i18n_backend.lookup(key, nil) || currency.public_send(key)
        else
          currency.public_send(key)
        end
      end

      private

      def i18n_backend
        @i18n_backend ||= Money::LocaleBackend::I18n.new
      end
    end
  end
end
