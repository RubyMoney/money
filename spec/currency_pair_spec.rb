# encoding: utf-8

require "spec_helper"

describe Money::CurrencyPair do

  subject(:currency_pair) { described_class.new('AUD', 'NZD') }

  describe "#to_s" do
    it "returns a string representation of a currency pair" do
      expect(currency_pair.to_s).to eq('AUDNZD')
    end
  end

  describe "#inverse" do
    it "returns the inverse pair" do
      expect(currency_pair.inverse).to eq(Money::CurrencyPair.new('NZD', 'AUD'))
    end
  end

  describe "#base" do
    it "Returns the base currency" do
      expect(currency_pair.base).to eq(Money::Currency.new('AUD'))
    end
  end

  describe "#counter" do
    it "Returns the counter currency" do
      expect(currency_pair.counter).to eq(Money::Currency.new('NZD'))
    end
  end

  describe "#==" do
    it "returns true if the base and counter currencies are the same" do
      other = Money::CurrencyPair.new('AUD', 'NZD')
      expect(currency_pair).to eq(other)
    end
  end

  describe "#eql?" do
    it "returns true if the base and counter currencies are the same" do
      other = Money::CurrencyPair.new('AUD', 'NZD')
      expect(currency_pair.eql?(other)).to be true
    end
  end

  describe ".wrap" do
    it "wraps a CurrencyPair object as a CurrencyPair" do
      expect(Money::CurrencyPair.wrap(currency_pair)).to eq(currency_pair)
    end
    it "wraps a string as a CurrencyPair" do
      expect(Money::CurrencyPair.wrap('AUDNZD')).to eq(currency_pair)
    end
    it "wraps a symbol as a CurrencyPair" do
      expect(Money::CurrencyPair.wrap(:audnzd)).to eq(currency_pair)
    end
  end
end
