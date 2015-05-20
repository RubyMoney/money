require 'spec_helper'

describe Money::RatesStore::Memory do
  let(:subject) { described_class.new }

  describe '#add_rate and #get_rate' do
    it 'stores rate in memory' do
      expect(subject.add_rate('USD', 'CAD', 0.9)).to eql 0.9
      expect(subject.get_rate('USD', 'CAD')).to eql 0.9
    end
  end

  describe 'add_rate' do
    it "uses a mutex by default" do
      expect(subject.instance_variable_get(:@mutex)).to receive(:synchronize)
      subject.add_rate('USD', 'EUR', 1.25)
    end

    it "doesn't use mutex if requested not to" do
      expect(subject.instance_variable_get(:@mutex)).not_to receive(:synchronize)
      subject.add_rate('USD', 'EUR', 1.25, :without_mutex => true)
    end
  end

  describe '#rates' do
    before do
      subject.add_rate("USD", "EUR", 0.788332676)
      subject.add_rate("EUR", "JPY", 122.631477)
    end

    it 'indexes added rates' do
      expect(subject.rates['USD_TO_EUR']).to eq 0.788332676
      expect(subject.rates['EUR_TO_JPY']).to eq 122.631477
    end
  end
end
