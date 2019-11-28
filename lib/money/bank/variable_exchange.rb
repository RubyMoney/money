require 'money/bank/base'
require 'money/rates_store/memory'
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
    # Exchange rates are stored in memory using +Money::RatesStore::Memory+ by default.
    # Pass custom rates stores for other types of storage (file, database, etc)
    #
    # @example
    #   bank = Money::Bank::VariableExchange.new
    #   bank.add_rate("USD", "CAD", 1.24515)
    #   bank.add_rate("CAD", "USD", 0.803115)
    #
    #   c1 = Money.new(100_00, "USD")
    #   c2 = Money.new(100_00, "CAD")
    #
    #   # Exchange 100 USD to CAD:
    #   bank.exchange_with(c1, "CAD") #=> #<Money fractional:12451 currency:CAD>
    #
    #   # Exchange 100 CAD to USD:
    #   bank.exchange_with(c2, "USD") #=> #<Money fractional:8031 currency:USD>
    #
    #   # With custom exchange rates storage
    #   redis_store = MyCustomRedisStore.new(host: 'localhost:6379')
    #   bank = Money::Bank::VariableExchange.new(redis_store)
    #   # Store rates in redis
    #   bank.add_rate 'USD', 'CAD', 0.98
    #   # Get rate from redis
    #   bank.get_rate 'USD', 'CAD'
    class VariableExchange < Base

      attr_reader :mutex

      # Available formats for importing/exporting rates.
      RATE_FORMATS = [:json, :ruby, :yaml].freeze
      SERIALIZER_SEPARATOR = '_TO_'.freeze
      FORMAT_SERIALIZERS = {json: JSON, ruby: Marshal, yaml: YAML}.freeze

      # Initializes a new +Money::Bank::VariableExchange+ object.
      # It defaults to using an in-memory, thread safe store instance for
      # storing exchange rates.
      #
      # @param [RateStore] st An exchange rate store, used to persist exchange rate pairs.
      # @yield [n] Optional block to use when rounding after exchanging one
      #  currency for another. See +Money::bank::base+
      def initialize(st = Money::RatesStore::Memory.new, &block)
        @store = st
        super(&block)
      end

      def store
        @store.is_a?(String) ? Object.const_get(@store) : @store
      end

      def marshal_dump
        [store.marshal_dump, @rounding_method]
      end

      def marshal_load(arr)
        store_info = arr[0]
        @store = store_info.shift.new(*store_info)
        @rounding_method = arr[1]
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
      #   c1 = Money.new(100_00, "USD")
      #   c2 = Money.new(100_00, "CAD")
      #
      #   # Exchange 100 USD to CAD:
      #   bank.exchange_with(c1, "CAD") #=> #<Money fractional:12451 currency:CAD>
      #
      #   # Exchange 100 CAD to USD:
      #   bank.exchange_with(c2, "USD") #=> #<Money fractional:8031 currency:USD>
      def exchange_with(from, to_currency, &block)
        to_currency = Currency.wrap(to_currency)
        if from.currency == to_currency
          from
        else
          if rate = get_rate(from.currency, to_currency)
            fractional = calculate_fractional(from, to_currency)
            from.class.new(
              exchange(fractional, rate, &block), to_currency
            )
          else
            raise UnknownRate, "No conversion rate known for '#{from.currency.iso_code}' -> '#{to_currency}'"
          end
        end
      end

      def calculate_fractional(from, to_currency)
        BigDecimal(from.fractional.to_s) / (
          BigDecimal(from.currency.subunit_to_unit.to_s) /
          BigDecimal(to_currency.subunit_to_unit.to_s)
        )
      end

      def exchange(fractional, rate, &block)
        ex = fractional * BigDecimal(rate.to_s)
        if block_given?
          yield ex
        elsif @rounding_method
          @rounding_method.call(ex)
        else
          ex
        end
      end

      # Registers a conversion rate and returns it (uses +#set_rate+).
      # Delegates to +Money::RatesStore::Memory+
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

      # Set the rate for the given currencies.
      # access.
      # Delegates to +Money::RatesStore::Memory+
      #
      # @param [Currency, String, Symbol] from Currency to exchange from.
      # @param [Currency, String, Symbol] to Currency to exchange to.
      # @param [Numeric] rate Rate to use when exchanging currencies.
      # @param [Hash] opts Options hash to set special parameters. Backwards compatibility only.
      #
      # @return [Numeric]
      #
      # @example
      #   bank = Money::Bank::VariableExchange.new
      #   bank.set_rate("USD", "CAD", 1.24515)
      #   bank.set_rate("CAD", "USD", 0.803115)
      def set_rate(from, to, rate, opts = {})
        store.add_rate(Currency.wrap(from).iso_code, Currency.wrap(to).iso_code, rate)
      end

      # Retrieve the rate for the given currencies.
      # data access.
      # Delegates to +Money::RatesStore::Memory+
      #
      # @param [Currency, String, Symbol] from Currency to exchange from.
      # @param [Currency, String, Symbol] to Currency to exchange to.
      # @param [Hash] opts Options hash to set special parameters. Backwards compatibility only.
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
      def get_rate(from, to, opts = {})
        store.get_rate(Currency.wrap(from).iso_code, Currency.wrap(to).iso_code)
      end

      # Return the known rates as a string in the format specified. If +file+
      # is given will also write the string out to the file specified.
      # Available formats are +:json+, +:ruby+ and +:yaml+.
      #
      # @param [Symbol] format Request format for the resulting string.
      # @param [String] file Optional file location to write the rates to.
      # @param [Hash] opts Options hash to set special parameters. Backwards compatibility only.
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
      def export_rates(format, file = nil, opts = {})
        raise Money::Bank::UnknownRateFormat unless
          RATE_FORMATS.include? format

        store.transaction do
          s = FORMAT_SERIALIZERS[format].dump(rates)

          unless file.nil?
            File.open(file, "w") {|f| f.write(s) }
          end

          s
        end
      end

      # This should be deprecated.
      def rates
        store.each_rate.each_with_object({}) do |(from,to,rate),hash|
          hash[[from, to].join(SERIALIZER_SEPARATOR)] = rate
        end
      end

      # Loads rates provided in +s+ given the specified format. Available
      # formats are +:json+, +:ruby+ and +:yaml+.
      # Delegates to +Money::RatesStore::Memory+
      #
      # @param [Symbol] format The format of +s+.
      # @param [String] s The rates string.
      # @param [Hash] opts Options hash to set special parameters. Backwards compatibility only.
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
      def import_rates(format, s, opts = {})
        raise Money::Bank::UnknownRateFormat unless
          RATE_FORMATS.include? format

        store.transaction do
          data = FORMAT_SERIALIZERS[format].load(s)

          data.each do |key, rate|
            from, to = key.split(SERIALIZER_SEPARATOR)
            store.add_rate from, to, rate
          end
        end

        self
      end
    end
  end
end
