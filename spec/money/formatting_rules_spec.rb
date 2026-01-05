# frozen_string_literal: true

RSpec.describe Money::FormattingRules do
  it "does not modify frozen rules in place" do
    expect do
      described_class.new(Money::Currency.new("USD"), { separator: "." }.freeze)
    end.not_to raise_error
  end

  it "does not modify rules in place" do
    rules = { separator: "." }
    new_rules = described_class.new(Money::Currency.new("USD"), rules)

    expect(rules).to eq(separator: ".")
    expect(rules).not_to eq(new_rules)
  end

  describe "format" do
    context "when there is a locale backend", :locale_backend_i18n do
      it "returns the format from the passed rules" do
        currency = Money::Currency.new("EUR")
        rules = { format: "%n%u", separator: ".", delimiter: "," }

        expect(described_class.new(currency, rules)[:format]).to eq("%n%u")
      end

      it "returns the translated format for the locale" do
        I18n.backend.store_translations(:fr, number: {
          currency: { format: { format: "%n %u" } },
        })
        currency = Money::Currency.new("EUR")
        rules = { separator: ".", delimiter: "," }

        expect(I18n.with_locale(:fr) { described_class.new(currency, rules)[:format] }).to eq("%n %u")
      end
    end

    context "when there is no locale backend" do
      it "returns the format from the passed rules" do
        allow(Money).to receive(:locale_backend).and_return(nil)
        currency = Money::Currency.new("EUR")
        rules = { format: "%n%u", separator: ".", delimiter: "," }

        expect(described_class.new(currency, rules)[:format]).to eq("%n%u")
      end

      it "returns the default format for the locale" do
        allow(Money).to receive(:locale_backend).and_return(nil)
        I18n.backend.store_translations(:fr, number: {
          currency: { format: { format: "%n %u" } },
        })
        currency = Money::Currency.new("EUR")
        rules = { separator: ".", delimiter: "," }
        allow(currency).to receive(:format).and_return("%u%n")

        expect(I18n.with_locale(:fr) { described_class.new(currency, rules)[:format] }).to eq("%u%n")
      end
    end
  end
end
