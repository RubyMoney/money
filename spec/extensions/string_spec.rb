# encoding: utf-8

require "spec_helper"

describe Money, "extension" do
  describe "#to_currency_name" do
    it "converts string to currency name" do
      expect('btc'.to_currency_name).to eq 'Bitcoin'
      expect('eth'.to_currency_name).to eq 'Ether'
      expect('twd'.to_currency_name).to eq 'New Taiwan Dollar'
      expect('cny'.to_currency_name).to eq 'Chinese Renminbi Yuan'
      expect('usd'.to_currency_name).to eq 'United States Dollar'
    end

    it "raises UnknownCurrency with unknown currency" do
      expect { 'ltc'.to_currency_name } .to raise_error Money::Currency::UnknownCurrency
    end
  end

  describe "#to_currency_code" do
    it "converts string to currency code" do
      expect('btc'.to_currency_code).to eq 'BTC'
      expect('eth'.to_currency_code).to eq 'ETH'
      expect('twd'.to_currency_code).to eq 'TWD'
      expect('usd'.to_currency_code).to eq 'USD'
    end

    it "raises UnknownCurrency with unknown currency" do
      expect { 'ltc'.to_currency_code } .to raise_error Money::Currency::UnknownCurrency
    end
  end

  describe "#to_currency_symbol" do
    it "converts string to currency symbol" do
      expect('btc'.to_currency_symbol).to eq 'B⃦'
      expect('eth'.to_currency_symbol).to eq 'Æ'
      expect('twd'.to_currency_symbol).to eq 'NT$'
      expect('cny'.to_currency_symbol).to eq '¥'
      expect('usd'.to_currency_symbol).to eq '$'
    end

    it "raises UnknownCurrency with unknown currency" do
      expect { 'ltc'.to_currency_symbol } .to raise_error Money::Currency::UnknownCurrency
    end
  end
end
