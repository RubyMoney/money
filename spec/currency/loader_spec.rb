# encoding: utf-8

describe Money::Currency::Loader do
  it "returns a currency table hash" do
    expect(subject.load_currencies).to be_a Hash
  end

  it "parse currency_iso.json & currency_non_iso.json & currency_backwards_compatible.json" do
    expect(subject).to receive(:parse_currency_file).exactly(3).times.and_return({})

    subject.load_currencies
  end
end
