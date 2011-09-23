module CurrencyLoader
  extend self

  DATA_PATH = File.dirname(__FILE__) + '/../../config/'

  # Loads and returns the currencies stored in JSON files in the config directory.
  #
  # @return [Hash]
  def load_currencies
    json = File.read(DATA_PATH + 'currency.json')
    currencies = JSON.parse(json, :symbolize_names => true)

    # merge the currencies kept for backwards compatibility
    json = File.read(DATA_PATH + 'currency_bc.json')
    currencies.merge!(JSON.parse(json, :symbolize_names => true))
  end
end
