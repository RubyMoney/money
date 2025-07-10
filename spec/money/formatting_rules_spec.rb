# frozen_string_literal: true

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
end
