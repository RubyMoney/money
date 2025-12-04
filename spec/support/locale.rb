# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :locale_backend_i18n) do
    Money.locale_backend = :i18n
  end

  config.after(:each, :locale_backend_i18n) do
    Money.locale_backend = :currency
  end

  config.before(:each, :locale_backend_currency) do
    Money.locale_backend = :currency
  end

  config.before(:each, :locale_backend_nil) do
    Money.locale_backend = nil
  end

  config.after(:each, :locale_backend_nil) do
    Money.locale_backend = :currency
  end
end
