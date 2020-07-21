class Money
  class Currency
    module Loader
      DATA_PATH = File.expand_path("../../../../config", __FILE__)

      class << self
        # Loads and returns the currencies stored in JSON files in the config directory.
        #
        # @return [Hash]
        def load_currencies
          currencies = parse_currency_file("currency_iso.json", supported: true)
          currencies.merge! parse_currency_file("currency_non_iso.json", supported: true)
          currencies.merge! parse_currency_file("currency_backwards_compatible.json", supported: false)
        end

        private

        def parse_currency_file(filename, opts)
          json = File.read("#{DATA_PATH}/#{filename}")
          json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
          JSON.parse(json, symbolize_names: true).each do |_key, curr|
            curr[:supported] = opts[:supported]
          end
        end
      end
    end
  end
end
