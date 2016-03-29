# encoding: utf-8

describe Money::Currency::Loader do
  class CurrencyLoader
    include Money::Currency::Loader
  end

  let(:loader) { CurrencyLoader.new }

  it "returns a currency table hash" do
    expect(loader.load_all).to be_a Hash
  end

  it "parse currency_iso.json & currency_non_iso.json & currency_backwards_compatible.json" do
    expect(loader).to receive(:load).exactly(3).times.and_return({})
    loader.load_all
  end
end
