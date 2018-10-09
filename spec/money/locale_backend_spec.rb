# encoding: utf-8

describe Money::LocaleBackend do
  describe '.find' do
    it 'returns an initialized backend' do
      expect(described_class.find(:i18n)).to be_a(Money::LocaleBackend::I18n)
      expect(described_class.find(:currency)).to be_a(Money::LocaleBackend::Currency)
    end

    it 'raises an error if a backend is unknown' do
      expect { described_class.find(:foo) }.to raise_error(Money::LocaleBackend::Unknown)
    end
  end
end
