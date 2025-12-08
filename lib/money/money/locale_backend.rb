# frozen_string_literal: true

require 'money/locale_backend/errors'
require 'money/locale_backend/i18n'
require 'money/locale_backend/currency'

class Money
  module LocaleBackend
    BACKENDS = {
      i18n: Money::LocaleBackend::I18n,
      currency: Money::LocaleBackend::Currency
    }.freeze

    def self.find(name)
      raise Unknown, "Unknown locale backend: #{name}" unless BACKENDS.key?(name)

      BACKENDS[name].new
    end
  end
end
