# frozen_string_literal: true

describe Money::FormattingRules do
  it 'does not modify frozen rules in place' do
    expect do
      Money::FormattingRules.new(Money::Currency.new('USD'), { separator: '.' }.freeze)
    end.not_to raise_error
  end

  it 'does not modify rules in place' do
    rules = { separator: '.' }
    new_rules = Money::FormattingRules.new(Money::Currency.new('USD'), rules)

    expect(rules).to eq(separator: '.')
    expect(rules).not_to eq(new_rules)
  end
end
