# encoding: UTF-8

class Money
  class FormattingRules
    def initialize(currency, *raw_rules)
      @currency = currency

      # support for old format parameters
      @rules = normalize_formatting_rules(raw_rules)

      @rules = default_formatting_rules.merge(@rules) unless @rules[:ignore_defaults]
      @rules = localize_formatting_rules(@rules)
      @rules = translate_formatting_rules(@rules) if @rules[:translate]
      @rules[:format] ||= determine_format_from_formatting_rules(@rules)

      warn_about_deprecated_rules(@rules)
    end

    def [](key)
      @rules[key]
    end

    def has_key?(key)
      @rules.has_key? key
    end

    private

    attr_reader :currency

    # Cleans up formatting rules.
    #
    # @param [Hash] rules
    #
    # @return [Hash]
    def normalize_formatting_rules(rules)
      if rules.size == 0
        rules = {}
      elsif rules.size == 1
        rules = rules.pop
        rules = rules.dup if rules.is_a?(Hash)

        if rules.is_a?(Symbol)
          warn '[DEPRECATION] Use Hash when passing rules to Money#format.'
          rules = { rules => true }
        end
      end

      if !rules.include?(:decimal_mark) && rules.include?(:separator)
        rules[:decimal_mark] = rules[:separator]
      end

      if !rules.include?(:thousands_separator) && rules.include?(:delimiter)
        rules[:thousands_separator] = rules[:delimiter]
      end

      rules
    end

    def default_formatting_rules
      Money.default_formatting_rules || {}
    end

    def translate_formatting_rules(rules)
      begin
        rules[:symbol] = I18n.t currency.iso_code, scope: "number.currency.symbol", raise: true
      rescue I18n::MissingTranslationData
        # Do nothing
      end
      rules
    end

    def localize_formatting_rules(rules)
      if currency.iso_code == "JPY" && I18n.locale == :ja
        rules[:symbol] = "円" unless rules[:symbol] == false
        rules[:format] = '%n%u'
      end
      rules
    end

    def determine_format_from_formatting_rules(rules)
      symbol_position = symbol_position_from(rules)

      if symbol_position == :before
        rules.fetch(:symbol_before_without_space, true) ? '%u%n' : '%u %n'
      else
        rules[:symbol_after_without_space] ? '%n%u' : '%n %u'
      end
    end

    def symbol_position_from(rules)
      if rules.has_key?(:symbol_position)
        if [:before, :after].include?(rules[:symbol_position])
          return rules[:symbol_position]
        else
          raise ArgumentError, ":symbol_position must be ':before' or ':after'"
        end
      elsif currency.symbol_first?
        :before
      else
        :after
      end
    end

    def warn_about_deprecated_rules(rules)
      if rules.has_key?(:symbol_position)
        position = rules[:symbol_position]
        template = position == :before ? '%u %n' : '%n %u'

        warn "[DEPRECATION] `symbol_position: :#{position}` is deprecated - you can replace it with `format: #{template}`"
      end

      if rules.has_key?(:symbol_before_without_space)
        warn "[DEPRECATION] `symbol_before_without_space:` option is deprecated - you can replace it with `format: '%u%n'`"
      end

      if rules.has_key?(:symbol_after_without_space)
        warn "[DEPRECATION] `symbol_after_without_space:` option is deprecated - you can replace it with `format: '%n%u'`"
      end

      if rules.has_key?(:html)
        warn "[DEPRECATION] `html` is deprecated - use `html_wrap` instead. Please note that `html_wrap` will wrap all parts of currency and if you use `with_currency` option, currency element class changes from `currency` to `money-currency`."
      end

      if rules.has_key?(:html_wrap_symbol)
        warn "[DEPRECATION] `html_wrap_symbol` is deprecated - use `html_wrap` instead. Please note that `html_wrap` will wrap all parts of currency."
      end
    end
  end
end
