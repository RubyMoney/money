# encoding: utf-8

require "spec_helper"

describe Money, "extension" do

  describe "#to_coin_name" do
    it "converts string to coin name" do
      expect('btc'.to_name).to eq 'Bitcoin'
      expect('eth'.to_name).to eq 'Ether'
      expect { 'ltc'.to_name } .to raise_error Money::Currency::UnknownCurrency
    end
  end

  describe "#to_money_name" do
    it "converts string to money name" do
      expect('cny'.to_name).to eq 'Chinese Renminbi Yuan'
      expect('usd'.to_name).to eq 'United States Dollar'
      expect('twd'.to_name).to eq 'New Taiwan Dollar'
    end
  end

  describe "#to_money_symbol" do
    it "converts string to money symbol" do
      expect('cny'.to_symbol).to eq '¥'
      expect('usd'.to_symbol).to eq '$'
      expect('twd'.to_symbol).to eq 'NT$'
    end
  end

end
