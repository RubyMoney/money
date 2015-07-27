# encoding: utf-8

require "spec_helper"

describe Money::Constructors do

  describe "::empty" do
    it "creates a new Money object of 0 cents" do
      expect(Money.empty).to eq Money.new(0)
    end

    it "memoizes the result" do
      expect(Money.empty.object_id).to eq Money.empty.object_id
    end

    it "memoizes a result for each currency" do
      expect(Money.empty(:cad).object_id).to eq Money.empty(:cad).object_id
    end

    it "doesn't allow money to be modified for a currency" do
      expect(Money.empty).to be_frozen
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

end
