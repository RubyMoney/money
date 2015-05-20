class Money
  module RatesStore
    class Memory
      attr_reader :rates

      def initialize(rt = {})
        @rates = rt
        @mutex = Mutex.new
      end

      def add_rate(currency_iso_from, currency_iso_to, rate, opts = {})
        transaction(opts) { rates[rate_key_for(currency_iso_from, currency_iso_to)] = rate }
      end

      def get_rate(currency_iso_from, currency_iso_to, opts = {})
        transaction(opts) { rates[rate_key_for(currency_iso_from, currency_iso_to)] }
      end

      def marshal_dump
        [self.class, rates]
      end

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
