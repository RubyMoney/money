# encoding: utf-8

require "spec_helper"

describe Money::Custom do

  it "returns currency matching given id" do
    expect(Money::Custom.exponent(:usd)).to eq 2.0
    expect(Money::Custom.exponent('usd')).to eq 2.0
    expect(Money::Custom.exponent(:btc)).to eq 8.0
    expect(Money::Custom.exponent('twd')).to eq 2.0
    expect(Money::Custom.exponent).to eq 8.0
  end

end

