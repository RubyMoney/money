class Money
  module RatesStore

    # Class for thread-safe storage of exchange rate pairs.
    # Used by instances of +Money::Bank::VariableExchange+.
    #
    # @example
    #   store = Money::RatesStore::Memory.new
    #   store.add_rate 'USD', 'CAD', 0.98
    #   store.get_rate 'USD', 'CAD' # => 0.98
    #   # import rates hash
    #   store.import_rates({'USD_TO_EUR' => 0.90})
    #   store.get_rate 'USD', 'EUR' => 0.90
    class Memory
      attr_reader :rates

      # Initializes a new +Money::RatesStore::Memory+ object.
      #
      # @param [Hash] rt Optional initial exchange rate data.
      def initialize(rt = {})
        @rates = rt
        @mutex = Mutex.new
      end

      # Registers a conversion rate and returns it. Uses +Mutex+ to synchronize data access.
      #
      # @param [String] currency_iso_from Currency to exchange from.
      # @param [String] currency_iso_to Currency to exchange to.
      # @param [Numeric] rate Rate to use when exchanging currencies.
      # @param [Hash] opts Options hash to set special parameters
      # @option opts [Boolean] :without_mutex disables the usage of a mutex
      #
      # @return [Numeric]
      #
      # @example
      #   store = Money::RatesStore::Memory.new
      #   store.add_rate("USD", "CAD", 1.24515)
      #   store.add_rate("CAD", "USD", 0.803115)
      def add_rate(currency_iso_from, currency_iso_to, rate, opts = {})
        transaction(opts) { rates[rate_key_for(currency_iso_from, currency_iso_to)] = rate }
      end

      # Retrieve the rate for the given currencies. Uses +Mutex+ to synchronize data access.
      # Delegates to +Money::RatesStore::Memory+
      #
      # @param [String] currency_iso_from Currency to exchange from.
      # @param [String] currency_iso_to Currency to exchange to.
      # @param [Hash] opts Options hash to set special parameters
      # @option opts [Boolean] :without_mutex disables the usage of a mutex
      #
      # @return [Numeric]
      #
      # @example
      #   store = Money::RatesStore::Memory.new
      #   store.add_rate("USD", "CAD", 1.24515)
      #
      #   store.get_rate("USD", "CAD") #=> 1.24515
      def get_rate(currency_iso_from, currency_iso_to, opts = {})
        transaction(opts) { rates[rate_key_for(currency_iso_from, currency_iso_to)] }
      end

      def marshal_dump
        [self.class, rates]
      end

      # Loads rates data hash.
      #
      # @param [Hash] data The rates data
      # @param [Hash] opts Options hash to set special parameters
      # @option opts [Boolean] :without_mutex disables the usage of a mutex
      #
      # @return [self]
      #
      # @raise +Money::Bank::UnknownRateFormat+ if format is unknown.
      #
      # @example
      #   data = {"USD_TO_CAD" => 1.24515, "CAD_TO_USD" => 0.803115}
      #   store = Money::RatesStore::Memory
      #   store.import_rates(:json, data)
      #
      #   store.get_rate("USD", "CAD") #=> 1.24515
      #   store.get_rate("CAD", "USD") #=> 0.803115
      def import_rates(data, opts = {})
        transaction(opts) { @rates = data }
        self
      end

      def transaction(opts = {}, &block)
        if opts[:without_mutex]
          block.call self
        else
          @mutex.synchronize(&block)
        end
      end

      private

      # Return the rate hashkey for the given currencies.
      #
      # @param [String] from The currency to exchange from.
      # @param [String] to The currency to exchange to.
      #
      # @return [String]
      #
      # @example
      #   rate_key_for("USD", "CAD") #=> "USD_TO_CAD"
      def rate_key_for(currency_iso_from, currency_iso_to)
        "#{currency_iso_from}_TO_#{currency_iso_to}".upcase
      end
    end
  end
end
