# frozen_string_literal: true

require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class Currency < Base
      def lookup(key, currency)
        if currency.respond_to?(key)
          currency.public_send(key)
        elsif key == :format
          format = currency.symbol_with_space? ? '%u %n' : '%u%n'
          currency.symbol_first? ? format : '%n %u'
        end
      end
    end
  end
end
