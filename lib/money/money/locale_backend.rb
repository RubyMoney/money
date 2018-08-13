# encoding: UTF-8

require 'money/locale_backend/errors'
require 'money/locale_backend/legacy'
require 'money/locale_backend/i18n'

class Money
  module LocaleBackend
    BACKENDS = {
      legacy: Money::LocaleBackend::Legacy,
      i18n: Money::LocaleBackend::I18n
    }.freeze

    def self.find(name)
      raise Unknown, "Unknown locale backend: #{name}" unless BACKENDS.key?(name)

      BACKENDS[name].new
    end
  end
end
