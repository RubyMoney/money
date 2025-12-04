# frozen_string_literal: true

I18n.enforce_available_locales = false

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end
