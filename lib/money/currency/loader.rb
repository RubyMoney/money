class Money
  class Currency
    module Loader
      DATA_PATH = File.expand_path("../../../../config", __FILE__).freeze
      FILES = %w(
        currency_iso.json
        currency_non_iso.json
        currency_backwards_compatible.json
      )

      extend self

      # Loads and returns the currencies stored in JSON files in the config directory.
      #
      # @return [Hash]
      def load_all
        FILES.inject({}) { |acc, x| acc.merge!(load(x)) }
      end

      def load(filename)
        json = File.read("#{DATA_PATH}/#{filename}")
        json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
        JSON.parse(json, symbolize_names: true).each_with_object({}) do |x, acc|
          acc[x[:code]] = x
        end
      end
    end
  end
end
