# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    I18n.enforce_available_locales = false
    I18n.backend = I18n::Backend::Simple.new
  end
end
