module DefaultCurrencyHelper

  def with_default_currency(iso_code)
    original_default = Money.default_currency
    begin
      Money.default_currency = Money::Currency.new(iso_code)
      yield
    ensure                                     
      Money.default_currency = original_default
    end
  end

end