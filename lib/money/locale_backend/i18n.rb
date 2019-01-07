require 'money/locale_backend/base'

class Money
  module LocaleBackend
    class I18n < Base
      KEY_MAP = {
        thousands_separator: :delimiter,
        decimal_mark: :separator,
        symbol: :unit
      }.freeze

      def initialize
        raise NotSupported, 'I18n not found' unless defined?(::I18n)
      end

      def lookup(key, _)
        i18n_key = KEY_MAP[key]

        ::I18n.t i18n_key, scope: 'number.currency.format', raise: true
      rescue ::I18n::MissingTranslationData
        ::I18n.t i18n_key, scope: 'number.format', default: nil
      end
    end
  end
end
