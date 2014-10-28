# encoding: utf-8

require "spec_helper"

describe Money, "extension" do

  describe "#to_money" do
    it "converts number to money with currency" do
      expect(12343543.to_money('cny')).to eq "¥123.44"
      expect(12343543.to_money('usd')).to eq "$123.44"
      expect(12343543.to_money('twd')).to eq "NT$123.44"
    end
  end

  describe "#to_round_money" do
    it "converts number to round money with currency" do
      expect(1234354300.to_round_money('cny')).to eq "¥12,344"
      expect(1234324300.to_round_money('usd')).to eq "$12,343"
      expect(1234354300.to_round_money('twd')).to eq "NT$12,344"
    end
  end

  describe "#to_ceil_money" do
    it "converts number to ceil money with currency" do
      expect(12343543.to_ceil_money('cny')).to eq "¥124.00"
      expect(12343543.to_ceil_money('usd')).to eq "$124.00"
      expect(12343543.to_ceil_money('twd')).to eq "NT$124.00"
    end
  end

  describe "#pure_money" do
    it "convert money from big integer value to float value" do
      expect(123426000.pure_money('cny')).to eq 1234.26
      expect(123486000.pure_money('usd')).to eq 1234.86
      expect(123486000.pure_money('twd')).to eq 1234.86
    end
  end

  describe "#pure_round_money" do
    it "convert money from big integer value to round integer value" do
      expect(123426000.pure_round_money('cny')).to eq 1234
      expect(123486000.pure_round_money('usd')).to eq 1235
      expect(123486000.pure_round_money('twd')).to eq 1235
    end
  end

  describe "#raw_floor_money" do
    it "convert money from big integer value to floor value" do
      expect(123426345.raw_floor_money('cny')).to eq 123426000
      expect(123426845.raw_floor_money('usd')).to eq 123426000
    end
  end

  describe "#raw_ceil_money" do
    it "convert money from big integer value to ceil value" do
      expect(123426345.raw_ceil_money('cny')).to eq 123427000
      expect(123426845.raw_ceil_money('usd')).to eq 123427000
    end
  end

  describe "#raw_money_for_fee" do
    it "gets the fee of big integer value to ceil value" do
      expect(100_00000.raw_money_for_fee(0.3, 'twd')).to eq 30_00000
      expect(100_00000.raw_money_for_fee(0, 'usd')).to eq 0
    end
  end

  describe "#f2i_money" do
    it "convert money from float value to big integer value" do
      expect(0.0.f2i_money).to eq 0
      expect(1.0.f2i_money).to eq 100000
      expect(0.123451.f2i_money).to eq 12345
      expect(0.123455.f2i_money).to eq 12346

      expect(0.0.f2i_money('usd')).to eq 0
      expect(1.0.f2i_money('usd')).to eq 100000
      expect(0.123451.f2i_money('usd')).to eq 12345
      expect(0.123455.f2i_money('usd')).to eq 12346
    end
  end

end