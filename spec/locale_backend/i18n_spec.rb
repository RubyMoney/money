# encoding: utf-8

describe Money::LocaleBackend::I18n do
  describe '#initialize' do
    it 'raises an error when I18n is not defined' do
      hide_const('I18n')

      expect { described_class.new }.to raise_error(Money::LocaleBackend::NotSupported)
    end
  end

  describe '#lookup' do
    after do
      reset_i18n
      I18n.locale = :en
    end

    subject { described_class.new }

    context 'with number.currency.format defined' do
      before do
        I18n.locale = :de
        I18n.backend.store_translations(:de, number: {
          currency: { format: { delimiter: '.', separator: ',', unit: '$' } }
        })
      end

      it 'returns thousands_separator based on the current locale' do
        expect(subject.lookup(:thousands_separator, nil)).to eq('.')
      end

      it 'returns decimal_mark based on the current locale' do
        expect(subject.lookup(:decimal_mark, nil)).to eq(',')
      end

      it 'returns symbol based on the current locale' do
        expect(subject.lookup(:symbol, nil)).to eq('$')
      end
    end

    context 'with number.format defined' do
      before do
        I18n.locale = :de
        I18n.backend.store_translations(:de, number: { format: { delimiter: '.', separator: ',' } })
      end

      it 'returns thousands_separator based on the current locale' do
        expect(subject.lookup(:thousands_separator, nil)).to eq('.')
      end

      it 'returns decimal_mark based on the current locale' do
        expect(subject.lookup(:decimal_mark, nil)).to eq(',')
      end
    end

    context 'with no translation defined' do
      it 'returns thousands_separator based on the current locale' do
        expect(subject.lookup(:thousands_separator, nil)).to eq(nil)
      end

      it 'returns decimal_mark based on the current locale' do
        expect(subject.lookup(:decimal_mark, nil)).to eq(nil)
      end

      it 'returns symbol based on the current locale' do
        expect(subject.lookup(:symbol, nil)).to eq(nil)
      end
    end
  end
end
