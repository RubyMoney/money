# frozen_string_literal: true

RSpec.describe Money::LocaleBackend::Currency do
  subject(:backend) { described_class.new }

  describe "#lookup" do
    let(:currency) { Money::Currency.new("EUR") }

    it "returns thousands_separator as defined in currency" do
      expect(backend.lookup(:thousands_separator, currency)).to eq(".")
    end

    it "returns decimal_mark based as defined in currency" do
      expect(backend.lookup(:decimal_mark, currency)).to eq(",")
    end

    it "returns format based as defined in currency" do
      expect(backend.lookup(:format, currency)).to be_nil
    end
  end
end
