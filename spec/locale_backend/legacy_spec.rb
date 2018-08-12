# encoding: utf-8

describe Money::LocaleBackend::Legacy do
  after { Money.use_i18n = true }

  describe '#initialize' do
    it 'raises an error when use_i18n is true and I18n is not defined' do
      Money.use_i18n = true
      hide_const('I18n')

      expect { described_class.new }.to raise_error(Money::LocaleBackend::NotSupported)
    end

    it 'does not raise error when use_i18n is false and I18n is not defined' do
      Money.use_i18n = false
      hide_const('I18n')

      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#lookup' do
    subject { described_class.new }
    let(:currency) { Money::Currency.new('USD') }

    context 'use_i18n is true and i18n lookup is successful' do
      before do
        allow(subject.send(:i18n_backend))
          .to receive(:lookup)
          .with(:thousands_separator, nil)
          .and_return('.')

        allow(subject.send(:i18n_backend))
          .to receive(:lookup)
          .with(:decimal_mark, nil)
          .and_return(',')
      end

      it 'returns thousands_separator from I18n' do
        expect(subject.lookup(:thousands_separator, currency)).to eq('.')
      end

      it 'returns decimal_mark based from I18n' do
        expect(subject.lookup(:decimal_mark, currency)).to eq(',')
      end
    end

    context 'use_i18n is true but i18n lookup is unsuccessful' do
      before do
        allow(subject.send(:i18n_backend)).to receive(:lookup).and_return(nil)
      end

      it 'returns thousands_separator as defined in currency' do
        expect(subject.lookup(:thousands_separator, currency)).to eq(',')
      end

      it 'returns decimal_mark based as defined in currency' do
        expect(subject.lookup(:decimal_mark, currency)).to eq('.')
      end
    end

    context 'use_i18n is false' do
      before { Money.use_i18n = false }

      it 'returns thousands_separator as defined in currency' do
        expect(subject.lookup(:thousands_separator, currency)).to eq(',')
      end

      it 'returns decimal_mark based as defined in currency' do
        expect(subject.lookup(:decimal_mark, currency)).to eq('.')
      end
    end
  end
end
