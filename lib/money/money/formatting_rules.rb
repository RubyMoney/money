# frozen_string_literal: true

class Money
  class FormattingRules
    def initialize(currency, *raw_rules)
      @currency = currency

      # support for old format parameters
      @rules = normalize_formatting_rules(raw_rules)

      @rules = default_formatting_rules.merge(@rules) unless @rules[:ignore_defaults]
      @rules = translate_formatting_rules(@rules) if @rules[:translate]
      @rules[:format] ||= determine_format
      @rules[:delimiter_pattern] ||= delimiter_pattern_rule(@rules)
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

    def determine_format
      Money.locale_backend&.lookup(:format, @currency) || default_format
    end

    def default_format
      if currency.format
        currency.format
      else
        currency.symbol_first? ? "%u%n" : "%n %u"
      end
    end

    def delimiter_pattern_rule(rules)
      if rules[:south_asian_number_formatting]
        # from https://blog.revathskumar.com/2014/11/regex-comma-seperated-indian-currency-format.html
        /(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/
      else
        /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
      end
    end
  end
end
