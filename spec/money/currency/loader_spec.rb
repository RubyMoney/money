# frozen_string_literal: true

RSpec.describe Money::Currency::Loader do
  it "returns a currency table hash" do
    expect(described_class.load_currencies).to be_a Hash
  end

  it "parse currency_iso.json & currency_non_iso.json & currency_backwards_compatible.json" do
    allow(described_class).to receive(:parse_currency_file).and_return({})

    described_class.load_currencies

    expect(described_class).to have_received(:parse_currency_file).exactly(3).times
  end
end
