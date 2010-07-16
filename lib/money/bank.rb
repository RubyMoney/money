require 'thread'

class Money
  class Bank
    class UnknownRate < StandardError; end

    def self.instance
      @@singleton
    end

    @@singleton = Bank.new

    def initialize(&block)
      @rates = {}
      @mutex = Mutex.new
      @rounding_method = block
    end

    def exchange(cents, from_currency, to_currency, &block)
      return cents if same_currency?(from_currency, to_currency)

      rate = get_rate(from_currency, to_currency)
      unless rate
        raise Money::Bank::UnknownRate, "No conversion rate known for '#{from_currency}' -> '#{to_currency}'"
      end
      _from_currency_ = Currency.wrap(from_currency)
      _to_currency_   = Currency.wrap(to_currency)

      _cents_ = cents / (_from_currency_.subunit_to_unit.to_f / _to_currency_.subunit_to_unit.to_f)

      ex = _cents_ * rate
      return block.call(ex) if block_given?
      return @rounding_method.call(ex) unless @rounding_method.nil?
      ex.to_s.to_i
    end

    def exchange_with(from, to_currency, &block)
      return from if same_currency?(from.currency, to_currency)

      rate = get_rate(from.currency, to_currency)
      unless rate
        raise Money::Bank::UnknownRate, "No conversion rate known for '#{from.currency.iso_code}' -> '#{to_currency}'"
      end
      _to_currency_  = Currency.wrap(to_currency)

      cents = from.cents / (from.currency.subunit_to_unit.to_f / _to_currency_.subunit_to_unit.to_f)

      ex = cents * rate
      ex = if block_given?
             block.call(ex)
           elsif @rounding_method
             @rounding_method.call(ex)
           else
             ex.to_s.to_i
           end
      Money.new(ex, _to_currency_)
    end

    private

    def rate_key_for(from, to)
      "#{Currency.wrap(from).iso_code}_TO_#{Currency.wrap(to).iso_code}".upcase
    end

    def set_rate(from, to, rate)
      @mutex.synchronize{ @rates[rate_key_for(from, to)] = rate }
    end

    def get_rate(from, to)
      @mutex.synchronize{ @rates[rate_key_for(from, to)] }
    end

    def same_currency?(currency1, currency2)
      Currency.wrap(currency1) == Currency.wrap(currency2)
    end
  end
end
