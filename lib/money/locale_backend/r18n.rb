require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class R18n < Base
      KEY_MAP = {
        thousands_separator: :number_group,
        decimal_mark: :number_decimal
      }.freeze

      def initialize
        raise NotSupported, 'R18n not found' unless defined?(::R18n)
      end

      def lookup(key, _)
        ::R18n.get.locale.public_send KEY_MAP[key]
      end
    end
  end
end
