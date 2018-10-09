# encoding: UTF-8

require 'money/locale_backend/errors'
require 'money/locale_backend/i18n'
require 'money/locale_backend/currency'
require 'money/locale_backend/r18n'

class Money
  module LocaleBackend
    BACKENDS = {
      i18n: Money::LocaleBackend::I18n,
      currency: Money::LocaleBackend::Currency,
      r18n: Money::LocaleBackend::R18n
    }.freeze

    DEFAULT = :currency

    def self.find(name)
      raise Unknown, "Unknown locale backend: #{name}" unless BACKENDS.key?(name)

      BACKENDS[name].new
    end
  end
end
