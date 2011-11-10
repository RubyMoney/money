require 'pathname'

module CurrencyLoader
  extend self

  DATA_PATH = Pathname.new(__FILE__).dirname + "../../config/"

  # Loads and returns the currencies stored in JSON files in the config directory.
  #
  # @return [Hash]
  def load_currencies
    json = File.read(DATA_PATH + 'currency.json')
    json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
    currencies = JSON.parse(json, :symbolize_names => true)

    # merge the currencies kept for backwards compatibility
    json = File.read(DATA_PATH + 'currency_bc.json')
    json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
    currencies.merge!(JSON.parse(json, :symbolize_names => true))
  end
end
