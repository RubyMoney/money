# frozen_string_literal: true

RSpec.describe Money::LocaleBackend::I18n do
  subject(:backend) { described_class.new }

  describe "#initialize" do
    it "raises an error when I18n is not defined" do
      hide_const("I18n")

      expect { described_class.new }.to raise_error(Money::LocaleBackend::NotSupported)
    end
  end

  describe "#lookup" do
    after do
      I18n.locale = :en
    end

    context "with number.currency.format defined" do
      before do
        I18n.locale = :de
        I18n.backend.store_translations(:de, number: {
          currency: { format: { delimiter: ".", separator: ",", unit: "$", format: "%u%n" } },
        })
      end

      it "returns thousands_separator based on the current locale" do
        expect(backend.lookup(:thousands_separator, nil)).to eq(".")
      end

      it "returns decimal_mark based on the current locale" do
        expect(backend.lookup(:decimal_mark, nil)).to eq(",")
      end

      it "returns symbol based on the current locale" do
        expect(backend.lookup(:symbol, nil)).to eq("$")
      end

      it "returns format based on the current locale" do
        expect(backend.lookup(:format, nil)).to eq("%u%n")
      end
    end

    context "with number.format defined" do
      before do
        I18n.locale = :de
        I18n.backend.store_translations(:de, number: { format: { delimiter: ".", separator: "," } })
      end

      it "returns thousands_separator based on the current locale" do
        expect(backend.lookup(:thousands_separator, nil)).to eq(".")
      end

      it "returns decimal_mark based on the current locale" do
        expect(backend.lookup(:decimal_mark, nil)).to eq(",")
      end
    end

    context "with no translation defined" do
      it "returns thousands_separator based on the current locale" do
        expect(backend.lookup(:thousands_separator, nil)).to be_nil
      end

      it "returns decimal_mark based on the current locale" do
        expect(backend.lookup(:decimal_mark, nil)).to be_nil
      end

      it "returns symbol based on the current locale" do
        expect(backend.lookup(:symbol, nil)).to be_nil
      end

      it "returns format based on the current locale" do
        expect(backend.lookup(:format, nil)).to be_nil
      end
    end
  end
end
