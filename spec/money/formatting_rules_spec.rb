# encoding: utf-8

describe Money::FormattingRules do
  it 'does not modify frozen rules in place' do
    expect {
      Money::FormattingRules.new(Money::Currency.new('USD'), { separator: '.' }.freeze)
    }.not_to raise_error
  end

  it 'does not modify rules in place' do
    rules = { separator: '.' }
    new_rules = Money::FormattingRules.new(Money::Currency.new('USD'), rules)

    expect(rules).to eq(separator: '.')
    expect(rules).not_to eq(new_rules)
  end

  context 'when the position is :before' do
    it 'warns about deprecated :symbol_position' do
      expect_any_instance_of(Money::FormattingRules).to receive(:warn)
        .with('[DEPRECATION] `symbol_position: :before` is deprecated - you can replace it with `format: %u%n`')

      Money::FormattingRules.new(Money::Currency.new('USD'), symbol_position: :before)
    end
  end

  context "when the position is :after" do
    it 'warns about deprecated :symbol_position' do
      expect_any_instance_of(Money::FormattingRules).to receive(:warn)
        .with('[DEPRECATION] `symbol_position: :after` is deprecated - you can replace it with `format: %n%u`')

      Money::FormattingRules.new(Money::Currency.new('USD'), symbol_position: :after)
    end
  end

  context "when translate is false" do
    it "ignores locale's format" do
      I18n.backend.store_translations(:fr, number: {
        currency: { format: { format: "%n %u" } }
      })
      # Have the currency's default symbol position be the opposite of the locale's format
      allow_any_instance_of(Money::Currency).to receive(:symbol_first).and_return(true)

      rules = I18n.with_locale(:fr) {Money::FormattingRules.new(Money::Currency.new('EUR'), translate: false)}

      expect(rules[:format]).to eq("%u%n")
    end
  end

  context "when translate is true" do
    it "uses locale's format by default" do
      I18n.backend.store_translations(:fr, number: {
        currency: { format: { format: "%n %u" } }
      })
      # Have the currency's default symbol position be the opposite of the locale's format
      allow_any_instance_of(Money::Currency).to receive(:symbol_first).and_return(true)

      rules = I18n.with_locale(:fr) {Money::FormattingRules.new(Money::Currency.new('EUR'), translate: true)}

      expect(rules[:format]).to eq("%n %u")
    end
  end
end
