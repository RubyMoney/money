# encoding: utf-8

describe Money::CurrencyMethods do
  describe "#as_*" do
    with_default_bank { Money::Bank::VariableExchange.new }
    before do
      Money.add_rate("EUR", "USD", 1)
      Money.add_rate("EUR", "CAD", 1)
      Money.add_rate("USD", "EUR", 1)
    end

    specify "as_us_dollar converts Money object to USD" do
      obj = Money.new(1, "EUR")
      expect(obj.as_us_dollar).to eq Money.new(1, "USD")
    end

    specify "as_ca_dollar converts Money object to CAD" do
      obj = Money.new(1, "EUR")
      expect(obj.as_ca_dollar).to eq Money.new(1, "CAD")
    end

    specify "as_euro converts Money object to EUR" do
      obj = Money.new(1, "USD")
      expect(obj.as_euro).to eq Money.new(1, "EUR")
    end
  end
end

describe Money::CurrencyMethods::ClassMethods do
  describe ".ca_dollar" do
    it "creates a new Money object of the given value in CAD" do
      expect(Money.ca_dollar(50)).to eq Money.new(50, "CAD")
    end

    it "is aliased to ::cad" do
      expect(Money.cad(50)).to eq Money.ca_dollar(50)
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.ca_dollar(0)).to be_a special_money_class
    end
  end


  describe ".us_dollar" do
    it "creates a new Money object of the given value in USD" do
      expect(Money.us_dollar(50)).to eq Money.new(50, "USD")
    end

    it "is aliased to ::usd" do
      expect(Money.usd(50)).to eq Money.us_dollar(50)
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.us_dollar(0)).to be_a special_money_class
    end
  end


  describe ".euro" do
    it "creates a new Money object of the given value in EUR" do
      expect(Money.euro(50)).to eq Money.new(50, "EUR")
    end

    it "is aliased to ::eur" do
      expect(Money.eur(50)).to eq Money.euro(50)
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.euro(0)).to be_a special_money_class
    end
  end


  describe ".pound_sterling" do
    it "creates a new Money object of the given value in GBP" do
      expect(Money.pound_sterling(50)).to eq Money.new(50, "GBP")
    end

    it "is aliased to ::gbp" do
      expect(Money.gbp(50)).to eq Money.pound_sterling(50)
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.pound_sterling(0)).to be_a special_money_class
    end
  end
end
