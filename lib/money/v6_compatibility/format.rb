class Money
  module V6Compatibility
    module_function

    def format
      Money.formatter = Formatter
      Money.prepend Formatting
    end

    module Formatting
      def format(old_rule = nil, **options)
        options = {old_rule => true} if old_rule.is_a?(Symbol)
        super(options)
      end
    end

    class Formatter < Money::Formatter
      def prepare_rules
        super
        {
          translate: :translate_symbol,
          south_asian_number_formatting: :south_asian,
          thousands_separator: :delimiter,
          decimal_mark: :separator,
          rounded_infinite_precision: :round,
        }.each do |old_key, new_key|
          rules[new_key] = rules[old_key] if rules.key?(old_key)
        end

        symbol_position = self.symbol_position
        if rules.key?(:symbol_after_without_space) && symbol_position == :after
          rules[:symbol_space] = !rules[:symbol_after_without_space]
        end
        if rules.key?(:symbol_before_without_space) && symbol_position == :before
          rules[:symbol_space] = !rules[:symbol_before_without_space]
        end

        localize_formatting_rules
      end

      def localize_formatting_rules
        if currency.code == 'JPY' && I18n.locale == :ja
          rules[:symbol] = '円' unless rules[:symbol] == false
          rules[:symbol_position] = :after
          rules[:symbol_space] = false
        end
      end

      alias_method :thousands_separator, :delimiter
      alias_method :decimal_mark, :separator
    end
  end
end
