require 'money/bank/base'
require 'json'
require 'yaml'

class Money
  module Bank
    # Thrown when an unknown rate format is requested.
    class UnknownRateFormat < StandardError; end

    # Class for aiding in exchanging money between different currencies. By
    # default, the +Money+ class uses an object of this class (accessible
    # through +Money#bank+) for performing currency exchanges.
    #
    # By default, +Money::Bank::VariableExchange+ has no knowledge about
    # conversion rates. One must manually specify them with +add_rate+, after
    # which one can perform exchanges with +#exchange_with+.
    #
    # @example
    #   bank = Money::Bank::VariableExchange.new
    #   bank.add_rate("USD", "CAD", 1.24515)
    #   bank.add_rate("CAD", "USD", 0.803115)
    #
    #   c1 = 100_00.to_money("USD")
    #   c2 = 100_00.to_money("CAD")
    #
    #   # Exchange 100 USD to CAD:
    #   bank.exchange_with(c1, "CAD") #=> #<Money @cents=1245150>
    #
    #   # Exchange 100 CAD to USD:
    #   bank.exchange_with(c2, "USD") #=> #<Money @cents=803115>
    class VariableExchange < Base

      attr_reader :rates

      # Available formats for importing/exporting rates.
      RATE_FORMATS = [:json, :ruby, :yaml]

      # Setup rates hash and mutex for rates locking
      #
      # @return [self]
      def setup
        @rates = {}
        @mutex = Mutex.new
        self
      end

      def marshal_dump
        [@rates, @rounding_method]
      end

      def marshal_load(arr)
        @rates, @rounding_method = arr
        @mutex = Mutex.new
      end

      # Exchanges the given +Money+ object to a new +Money+ object in
      # +to_currency+.
      #
      # @param  [Money] from
      #         The +Money+ object to exchange.
      # @param  [Currency, String, Symbol] to_currency
      #         The currency to exchange to.
      #
      # @yield [n] Optional block to use when rounding after exchanging one
      #  currency for another.
      # @yieldparam [Float] n The resulting float after exchanging one currency
      #  for another.
      # @yieldreturn [Integer]
      #
      # @return [Money]
      #
      # @raise +Money::Bank::UnknownRate+ if the conversion rate is unknown.
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.add_rate("USD", "CAD", 1.24515)
      #   bank.add_rate("CAD", "USD", 0.803115)
      #
      #   c1 = 100_00.to_money("USD")
      #   c2 = 100_00.to_money("CAD")
      #
      #   # Exchange 100 USD to CAD:
      #   bank.exchange_with(c1, "CAD") #=> #<Money @cents=1245150>
      #
      #   # Exchange 100 CAD to USD:
      #   bank.exchange_with(c2, "USD") #=> #<Money @cents=803115>
      def exchange_with(from, to_currency)
        return from if same_currency?(from.currency, to_currency)

        rate = get_rate(from.currency, to_currency)
        unless rate
          raise UnknownRate, "No conversion rate known for '#{from.currency.iso_code}' -> '#{to_currency}'"
        end
        _to_currency_  = Currency.wrap(to_currency)

        cents = BigDecimal.new(from.cents.to_s) / (BigDecimal.new(from.currency.subunit_to_unit.to_s) / BigDecimal.new(_to_currency_.subunit_to_unit.to_s))

        ex = cents * BigDecimal.new(rate.to_s)
        ex = ex.to_f
        ex = if block_given?
               yield ex
             elsif @rounding_method
               @rounding_method.call(ex)
             else
               ex.to_s.to_i
             end
        Money.new(ex, _to_currency_)
      end

      # Registers a conversion rate and returns it (uses +#set_rate+).
      #
      # @param [Currency, String, Symbol] from Currency to exchange from.
      # @param [Currency, String, Symbol] to Currency to exchange to.
      # @param [Numeric] rate Rate to use when exchanging currencies.
      #
      # @return [Numeric]
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.add_rate("USD", "CAD", 1.24515)
      #   bank.add_rate("CAD", "USD", 0.803115)
      def add_rate(from, to, rate)
        set_rate(from, to, rate)
      end

      # Set the rate for the given currencies. Uses +Mutex+ to synchronize data
      # access.
      #
      # @param [Currency, String, Symbol] from Currency to exchange from.
      # @param [Currency, String, Symbol] to Currency to exchange to.
      # @param [Numeric] rate Rate to use when exchanging currencies.
      #
      # @return [Numeric]
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.set_rate("USD", "CAD", 1.24515)
      #   bank.set_rate("CAD", "USD", 0.803115)
      def set_rate(from, to, rate)
        @mutex.synchronize { @rates[rate_key_for(from, to)] = rate }
      end

      # Retrieve the rate for the given currencies. Uses +Mutex+ to synchronize
      # data access.
      #
      # @param [Currency, String, Symbol] from Currency to exchange from.
      # @param [Currency, String, Symbol] to Currency to exchange to.
      #
      # @return [Numeric]
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.set_rate("USD", "CAD", 1.24515)
      #   bank.set_rate("CAD", "USD", 0.803115)
      #
      #   bank.get_rate("USD", "CAD") #=> 1.24515
      #   bank.get_rate("CAD", "USD") #=> 0.803115
      def get_rate(from, to)
        @mutex.synchronize { @rates[rate_key_for(from, to)] }
      end

      # Return the known rates as a string in the format specified. If +file+
      # is given will also write the string out to the file specified.
      # Available formats are +:json+, +:ruby+ and +:yaml+.
      #
      # @param [Symbol] format Request format for the resulting string.
      # @param [String] file Optional file location to write the rates to.
      #
      # @return [String]
      #
      # @raise +Money::Bank::UnknownRateFormat+ if format is unknown.
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.set_rate("USD", "CAD", 1.24515)
      #   bank.set_rate("CAD", "USD", 0.803115)
      #
      #   s = bank.export_rates(:json)
      #   s #=> "{\"USD_TO_CAD\":1.24515,\"CAD_TO_USD\":0.803115}"
      def export_rates(format, file=nil)
        raise Money::Bank::UnknownRateFormat unless
          RATE_FORMATS.include? format

        s = ""
        @mutex.synchronize {
          s = case format
              when :json
                JSON.dump(@rates)
              when :ruby
                Marshal.dump(@rates)
              when :yaml
                YAML.dump(@rates)
              end

          unless file.nil?
            File.open(file, "w") {|f| f.write(s) }
          end
        }
        s
      end

      # Loads rates provided in +s+ given the specified format. Available
      # formats are +:json+, +:ruby+ and +:yaml+.
      #
      # @param [Symbol] format The format of +s+.
      # @param [String] s The rates string.
      #
      # @return [self]
      #
      # @raise +Money::Bank::UnknownRateFormat+ if format is unknown.
      #
      # @example
      #   s = "{\"USD_TO_CAD\":1.24515,\"CAD_TO_USD\":0.803115}"
      #   bank = Money::Bank::VariableExchange.new
      #   bank.import_rates(:json, s)
      #
      #   bank.get_rate("USD", "CAD") #=> 1.24515
      #   bank.get_rate("CAD", "USD") #=> 0.803115
      def import_rates(format, s)
        raise Money::Bank::UnknownRateFormat unless
          RATE_FORMATS.include? format

        @mutex.synchronize {
          @rates = case format
                   when :json
                     JSON.load(s)
                   when :ruby
                     Marshal.load(s)
                   when :yaml
                     YAML.load(s)
                   end
        }
        self
      end

      private

      # Return the rate hashkey for the given currencies.
      #
      # @param [Currency, String, Symbol] from The currency to exchange from.
      # @param [Currency, String, Symbol] to The currency to exchange to.
      #
      # @return [String]
      #
      # @example
      #   rate_key_for("USD", "CAD") #=> "USD_TO_CAD"
      def rate_key_for(from, to)
        "#{Currency.wrap(from).iso_code}_TO_#{Currency.wrap(to).iso_code}".upcase
      end
    end
  end
end
