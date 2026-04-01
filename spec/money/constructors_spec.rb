# frozen_string_literal: true

RSpec.describe Money::Constructors do
  describe "::empty" do
    it "creates a new Money object of 0 cents" do
      expect(Money.empty).to eq Money.new(0)
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.empty).to be_a special_money_class
    end
  end

  describe "::zero" do
    subject { Money.zero }

    it { is_expected.to eq Money.empty }

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      expect(special_money_class.zero).to be_a special_money_class
    end
  end

  describe "::ca_dollar" do
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

  describe "::us_dollar" do
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

  describe "::euro" do
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

  describe "::pound_sterling" do
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

  describe ".currency_helpers=" do
    it "allows adding new currency helper methods" do
      money_class = Class.new(Money)
      money_class.currency_helpers = { jpy: "JPY", yen: "JPY" }

      expect(money_class.jpy(1000)).to eq Money.new(1000, "JPY")
      expect(money_class.yen(500)).to eq Money.new(500, "JPY")
    end

    it "creates as_ instance methods for currency exchange" do
      money_class = Class.new(Money)
      money_class.currency_helpers = { jpy: "JPY" }

      Money.add_rate("USD", "JPY", 150)
      money = money_class.new(100, "USD")

      expect(money).to respond_to(:as_jpy)
      expect(money.as_jpy).to eq money.exchange_to("JPY")
    end
  end
end
