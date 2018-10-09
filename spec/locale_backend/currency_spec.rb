# encoding: utf-8

describe Money::LocaleBackend::Currency do
  describe '#lookup' do
    let(:usd) { Money::Currency.new('USD') }
    let(:nok) { Money::Currency.new('NOK') }

    it 'returns thousands_separator as defined in currency' do
      expect(subject.lookup(:thousands_separator, usd)).to eq(',')
      expect(subject.lookup(:thousands_separator, nok)).to eq('.')
    end

    it 'returns decimal_mark as defined in currency' do
      expect(subject.lookup(:decimal_mark, usd)).to eq('.')
      expect(subject.lookup(:decimal_mark, nok)).to eq(',')
    end

    it 'returns format based on currency' do
      expect(subject.lookup(:format, usd)).to eq('%u%n')
      expect(subject.lookup(:format, nok)).to eq('%n %u')
    end
  end
end
