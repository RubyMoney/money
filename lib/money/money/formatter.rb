class Money
  class Formatter
    def initialize(obj, rules)
      self.obj = obj
      self.rules = sanitize_rules(rules)
    end

    def format
      if obj.fractional == 0
        if rules[:display_free].respond_to?(:to_str)
          return rules[:display_free]
        elsif rules[:display_free]
          return "free"
        end
      end

      symbol_value = symbol_value_from(rules)

      formatted = obj.abs.to_s

      if rules[:rounded_infinite_precision]
        formatted = ((BigDecimal(formatted) * obj.currency.subunit_to_unit).round / BigDecimal(obj.currency.subunit_to_unit.to_s)).to_s("F")
        formatted.gsub!(/\..*/) do |decimal_part|
          decimal_part << '0' while decimal_part.length < (obj.currency.decimal_places + 1)
          decimal_part
        end
      end

      sign = obj.negative? ? '-' : ''

      if rules[:no_cents] || (rules[:no_cents_if_whole] && obj.cents % obj.currency.subunit_to_unit == 0)
        formatted = "#{formatted.to_i}"
      end

      thousands_separator_value = obj.thousands_separator
      # Determine thousands_separator
      if rules.has_key?(:thousands_separator)
        thousands_separator_value = rules[:thousands_separator] || ''
      end

      # Apply thousands_separator
      formatted.gsub!(regexp_format(formatted, rules, obj.decimal_mark, symbol_value),
                      "\\1#{thousands_separator_value}")

      symbol_position = symbol_position_from(rules)

      if rules[:sign_positive] == true && obj.positive?
        sign = '+'
      end

      if rules[:sign_before_symbol] == true
        sign_before = sign
        sign = ''
      end

      if symbol_value && !symbol_value.empty?
        symbol_value = "<span class=\"currency_symbol\">#{symbol_value}</span>" if rules[:html_wrap_symbol]

        formatted = if symbol_position == :before
                      symbol_space = rules[:symbol_before_without_space] === false ? " " : ""
                      "#{sign_before}#{symbol_value}#{symbol_space}#{sign}#{formatted}"
                    else
                      symbol_space = rules[:symbol_after_without_space] ? "" : " "
                      "#{sign_before}#{formatted}#{symbol_space}#{sign}#{symbol_value}"
                    end
      end

      if rules.has_key?(:decimal_mark) && rules[:decimal_mark] &&
        rules[:decimal_mark] != obj.decimal_mark
        formatted.sub!(obj.decimal_mark, rules[:decimal_mark])
      end

      if rules[:with_currency]
        formatted << " "
        formatted << '<span class="currency">' if rules[:html]
        formatted << obj.currency.to_s
        formatted << '</span>' if rules[:html]
      end
      formatted
    end

    private

    attr_accessor :obj, :rules

    def sanitize_rules(rules)
      rules = normalize_formatting_rules(rules)
      rules = localize_formatting_rules(rules)
      rules
    end

    def normalize_formatting_rules(rules)
      if rules.size == 0
        rules = {}
      elsif rules.size == 1
        rules = rules.pop
        rules = { rules => true } if rules.is_a?(Symbol)
      end
      if !rules.include?(:decimal_mark) && rules.include?(:separator)
        rules[:decimal_mark] = rules[:separator]
      end
      if !rules.include?(:thousands_separator) && rules.include?(:delimiter)
        rules[:thousands_separator] = rules[:delimiter]
      end
      rules
    end

    def localize_formatting_rules(rules)
      if obj.currency.iso_code == "JPY" && I18n.locale == :ja
        rules[:symbol] = "円" unless rules[:symbol] == false
        rules[:symbol_position] = :after
        rules[:symbol_after_without_space] = true
      end
      rules
    end

    def regexp_format(formatted, rules, decimal_mark, symbol_value)
      regexp_decimal = Regexp.escape(decimal_mark)
      if rules[:south_asian_number_formatting]
        /(\d+?)(?=(\d\d)+(\d)(?:\.))/
      else
        # Symbols may contain decimal marks (E.g "դր.")
        if formatted.sub(symbol_value.to_s, "") =~ /#{regexp_decimal}/
          /(\d)(?=(?:\d{3})+(?:#{regexp_decimal}))/
        else
          /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
        end
      end
    end

    def symbol_value_from(rules)
      if rules.has_key?(:symbol)
        if rules[:symbol] === true
          obj.symbol
        elsif rules[:symbol]
          rules[:symbol]
        else
          ""
        end
      elsif rules[:html]
        obj.currency.html_entity == '' ? obj.currency.symbol : obj.currency.html_entity
      else
        obj.symbol
      end
    end

    def symbol_position_from(rules)
      if rules.has_key?(:symbol_position)
        rules[:symbol_position]
      elsif obj.currency.symbol_first?
        :before
      else
        :after
      end
    end
  end
end
