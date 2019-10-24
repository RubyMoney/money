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
      expect(subject.instance_variable_get(:@guard)).to receive(:synchronize)
      subject.add_rate('USD', 'EUR', 1.25)
    end
  end

  describe '#each_rate' do
    before do
      subject.add_rate('USD', 'CAD', 0.9)
      subject.add_rate('CAD', 'USD', 1.1)
    end

    it 'iterates over rates' do
      expect{|b| subject.each_rate(&b)}.to yield_successive_args(['USD', 'CAD', 0.9], ['CAD', 'USD', 1.1])
    end

    it 'is an Enumeator' do
      expect(subject.each_rate).to be_kind_of(Enumerator)
      result = subject.each_rate.each_with_object({}){|(from, to, rate),m| m[[from,to].join] = rate}
      expect(result).to match({'USDCAD' => 0.9, 'CADUSD' => 1.1})
    end
  end

  describe '#transaction' do
    context 'mutex' do
      it 'uses mutex' do
        expect(subject.instance_variable_get('@guard')).to receive(:synchronize)
        subject.transaction{ 1 + 1 }
      end

      it 'wraps block in mutex transaction only once' do
        expect{
          subject.transaction do
            subject.add_rate('USD', 'CAD', 1)
          end
        }.not_to raise_error
      end
    end
  end

  describe '#marshal_dump' do
    let(:subject) { Money::RatesStore::Memory.new(optional: true) }

    it 'can reload' do
      bank = Money::Bank::VariableExchange.new(subject)
      bank = Marshal.load(Marshal.dump(bank))
      expect(bank.store.instance_variable_get(:@options)).to eq subject.instance_variable_get(:@options)
      expect(bank.store.instance_variable_get(:@index)).to eq subject.instance_variable_get(:@index)
    end
  end
end
