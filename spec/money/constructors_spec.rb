# frozen_string_literal: true

describe Money::Constructors do

  describe "::empty" do
    it "creates a new Money object of 0 cents" do
      Money.default_currency = :usd
      expect(Money.empty).to eq Money.new(0, "USD")
      Money.default_currency = nil
    end

    it "instantiates a subclass when inheritance is used" do
      special_money_class = Class.new(Money)
      special_money_class.default_currency = :usd
      expect(special_money_class.empty).to be_a special_money_class
      special_money_class.default_currency = nil
    end
  end


  describe "::zero" do
    subject { Money.default_currency = :usd;Money.zero }
    it { is_expected.to eq Money.empty;Money.default_currency = nil }

    it "instantiates a subclass when inheritance is used" do
      Money.default_currency = :usd
      special_money_class = Class.new(Money)
      expect(special_money_class.zero).to be_a special_money_class
      Money.default_currency = nil
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

end
