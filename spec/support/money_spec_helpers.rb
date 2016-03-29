module MoneySpecHelpers
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def with_locale(locale, translations = nil)
      around { |ex| with_locale(locale, translations) { ex.run } }
    end

    %w(
      use_i18n
      flush_currencies
    ).each do |method|
      define_method method do |val = nil, &block|
        around { |ex| send(method, block && instance_exec(&block) || val) { ex.run } }
      end
    end

    %w(
      currency
      default_bank
      default_currency
      infinite_precision
      rounding_mode
    ).each do |suffix|
      method = "with_#{suffix}"
      define_method method do |val = nil, &block|
        around { |ex| send(method, block && instance_exec(&block) || val) { ex.run } }
      end
    end
  end

  def with_locale(locale, translations = nil)
    reset_i18n
    I18n.backend.store_translations(locale, translations) if translations
    I18n.with_locale(locale) { yield }
  ensure
    reset_i18n
  end

  def reset_i18n
    I18n.backend = I18n::Backend::Simple.new
  end

  def use_i18n(val)
    old = Money.formatter.use_i18n
    Money.formatter.use_i18n = val
    yield
  ensure
    Money.formatter.use_i18n = old
  end

  def with_currency(attrs)
    Money::Currency.register(attrs)
    yield
  ensure
    Money::Currency.unregister(attrs)
  end

  def flush_currencies(*)
    old = Money::Currency.codes
    yield
  ensure
    created = Money::Currency.codes - old
    created.each { |x| Money::Currency.unregister(x) }
  end

  %w(
    default_bank
    default_currency
    infinite_precision
    rounding_mode
  ).each do |field|
    define_method "with_#{field}" do |val, &block|
      begin
        old = Money.send(field)
        Money.send "#{field}=", val
        block.call
      ensure
        Money.send "#{field}=", old
      end
    end
  end
end

RSpec.shared_context 'with infinite precision', :infinite_precision do
  with_infinite_precision(true)
end
