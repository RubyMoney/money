# encoding: utf-8

require "spec_helper"

describe Money, "extension" do

  describe "#to_coin_name" do
    it "converts string to coin name" do
      expect('btc'.to_coin_name).to eq 'BTC'
      expect { 'ltc'.to_coin_name } .to raise_error Money::Currency::UnknownCurrency
    end
  end

  describe "#to_money_name" do
    it "converts string to money name" do
      expect('cny'.to_money_name).to eq 'Chinese Renminbi Yuan'
      expect('usd'.to_money_name).to eq 'United States Dollar'
      expect('twd'.to_money_name).to eq 'New Taiwan Dollar'
    end
  end

  describe "#to_money_symbol" do
    it "converts string to money symbol" do
      expect('cny'.to_money_symbol).to eq '¥'
      expect('usd'.to_money_symbol).to eq '$'
      expect('twd'.to_money_symbol).to eq 'NT$'
    end
  end

end