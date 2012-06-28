module CurrencyLoader
  extend self

  DATA_PATH = File.expand_path("../../../config", __FILE__)

  # Loads and returns the currencies stored in YAML files in the config
  # directory.
  #
  # @return [Hash]
  def load_currencies
    currencies = parse_currency_file("currency.yml")
    currencies.merge! parse_currency_file("currency_bc.yml")
  end

  private

  def parse_currency_file(filename)
    YAML.load_file("#{DATA_PATH}/#{filename}")
  end
end
