# encoding: utf-8

describe Money::LocaleBackend::R18n do
  describe '#initialize' do
    it 'raises an error when R18n is not defined' do
      hide_const('R18n')

      expect { described_class.new }.to raise_error(Money::LocaleBackend::NotSupported)
    end
  end

  describe '#lookup' do
    before do
      R18n.default_loader = Class.new do
        def available
          %i[de].map { |locale| R18n.locale locale }
        end

        def load(_locale)
          {}
        end
      end
    end

    after do
      R18n.reset!
      R18n.set :en
    end

    subject { described_class.new }

    context 'with available locale' do
      before do
        R18n.set :de
      end

      it 'returns thousands_separator based on the current locale' do
        expect(subject.lookup(:thousands_separator, nil)).to eq('.')
      end

      it 'returns decimal_mark based on the current locale' do
        expect(subject.lookup(:decimal_mark, nil)).to eq(',')
      end
    end

    context 'with unavailable locale' do
      before do
        R18n.set :unavailable
      end

      it 'returns thousands_separator based on the current locale' do
        expect(subject.lookup(:thousands_separator, nil)).to eq(',')
      end

      it 'returns decimal_mark based on the current locale' do
        expect(subject.lookup(:decimal_mark, nil)).to eq('.')
      end
    end
  end
end
