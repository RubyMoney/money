# encoding: utf-8

describe Money::LocaleBackend::Currency do
  describe '#lookup' do
    let(:currency) { Money::Currency.new('EUR') }

    it 'returns thousands_separator as defined in currency' do
      expect(subject.lookup(:thousands_separator, currency)).to eq('.')
    end

    it 'returns decimal_mark based as defined in currency' do
      expect(subject.lookup(:decimal_mark, currency)).to eq(',')
    end
  end
end
