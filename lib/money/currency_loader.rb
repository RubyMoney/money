module CurrencyLoader
  extend self

  # Loads and returns the currencies stored in JSON files in the data directory.
  #
  # @return [Hash]
  def load_currencies
    data_path = File.dirname(__FILE__) + '/data/'

    json = File.read(data_path + 'currency.json')
    currencies = JSON.parse(json, :symbolize_names => true)

    # merge the currencies kept for backwards compatibility
    json = File.read(data_path + 'currency_bc.json')
    currencies.merge!(JSON.parse(json, :symbolize_names => true))
  end
end
