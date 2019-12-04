require 'monitor'

class Money
  module RatesStore

    # Class for thread-safe storage of exchange rate pairs.
    # Used by instances of +Money::Bank::VariableExchange+.
    #
    # @example
    #   store = Money::RatesStore::Memory.new
    #   store.add_rate 'USD', 'CAD', 0.98
    #   store.get_rate 'USD', 'CAD' # => 0.98
    #   # iterates rates
    #   store.each_rate {|iso_from, iso_to, rate| puts "#{from} -> #{to}: #{rate}" }
    class Memory
      INDEX_KEY_SEPARATOR = '_TO_'.freeze

      # Initializes a new +Money::RatesStore::Memory+ object.
      #
      # @param [Hash] opts Optional store options.
      # @option opts [Boolean] :without_mutex disables the usage of a mutex
      # @param [Hash] rt Optional initial exchange rate data.
      def initialize(opts = {}, rates = {})
        @rates = rates
        @options = opts
        @guard = Monitor.new
      end

      # Registers a conversion rate and returns it. Uses +Mutex+ to synchronize data access.
      #
      # @param [String] currency_iso_from Currency to exchange from.
      # @param [String] currency_iso_to Currency to exchange to.
      # @param [Numeric] rate Rate to use when exchanging currencies.
      #
      # @return [Numeric]
      #
      # @example
      #   store = Money::RatesStore::Memory.new
      #   store.add_rate("USD", "CAD", 1.24515)
      #   store.add_rate("CAD", "USD", 0.803115)
      def add_rate(currency_iso_from, currency_iso_to, rate)
        guard.synchronize do
          rates[rate_key_for(currency_iso_from, currency_iso_to)] = rate
        end
      end

      # Retrieve the rate for the given currencies. Uses +Mutex+ to synchronize data access.
      # Delegates to +Money::RatesStore::Memory+
      #
      # @param [String] currency_iso_from Currency to exchange from.
      # @param [String] currency_iso_to Currency to exchange to.
      #
      # @return [Numeric]
      #
      # @example
      #   store = Money::RatesStore::Memory.new
      #   store.add_rate("USD", "CAD", 1.24515)
      #
      #   store.get_rate("USD", "CAD") #=> 1.24515
      def get_rate(currency_iso_from, currency_iso_to)
        guard.synchronize do
          rates[rate_key_for(currency_iso_from, currency_iso_to)]
        end
      end

      def marshal_dump
        guard.synchronize do
          return [self.class, options, rates.dup]
        end
      end

      # Wraps block execution in a thread-safe transaction
      def transaction(&block)
        guard.synchronize do
          yield
        end
      end

      # Iterate over rate tuples (iso_from, iso_to, rate)
      #
      # @yieldparam iso_from [String] Currency ISO string.
      # @yieldparam iso_to [String] Currency ISO string.
      # @yieldparam rate [Numeric] Exchange rate.
      #
      # @return [Enumerator]
      #
      # @example
      #   store.each_rate do |iso_from, iso_to, rate|
      #     puts [iso_from, iso_to, rate].join
      #   end
      def each_rate(&block)
        return to_enum(:each_rate) unless block_given?

        guard.synchronize do
          rates.each do |key, rate|
            iso_from, iso_to = key.split(INDEX_KEY_SEPARATOR)
            yield iso_from, iso_to, rate
          end
        end
      end

      private

      attr_reader :rates, :options, :guard

      # Return the rate hashkey for the given currencies.
      #
      # @param [String] currency_iso_from The currency to exchange from.
      # @param [String] currency_iso_to The currency to exchange to.
      #
      # @return [String]
      #
      # @example
      #   rate_key_for("USD", "CAD") #=> "USD_TO_CAD"
      def rate_key_for(currency_iso_from, currency_iso_to)
        [currency_iso_from, currency_iso_to].join(INDEX_KEY_SEPARATOR).upcase
      end
    end
  end
end
