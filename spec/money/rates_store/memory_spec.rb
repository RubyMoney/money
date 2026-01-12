# frozen_string_literal: true

RSpec.describe Money::RatesStore::Memory do
  subject(:store) { described_class.new }

  describe "#add_rate and #get_rate" do
    it "stores rate in memory" do
      expect(store.add_rate("USD", "CAD", 0.9)).to be 0.9
      expect(store.get_rate("USD", "CAD")).to be 0.9
    end
  end

  describe "add_rate" do
    let(:guard) { store.instance_variable_get(:@guard) }

    before do
      allow(guard).to receive(:synchronize)
    end

    it "uses a mutex by default" do
      store.add_rate("USD", "EUR", 1.25)

      expect(guard).to have_received(:synchronize)
    end
  end

  describe "#each_rate" do
    before do
      store.add_rate("USD", "CAD", 0.9)
      store.add_rate("CAD", "USD", 1.1)
    end

    it "iterates over rates" do
      expect { |b| store.each_rate(&b) }.to yield_successive_args(["USD", "CAD", 0.9], ["CAD", "USD", 1.1])
    end

    it "is an Enumeator" do
      expect(store.each_rate).to be_a(Enumerator)
      result = store.each_rate.with_object({}) { |(from, to, rate), m| m[[from, to].join] = rate }
      expect(result).to match({ "USDCAD" => 0.9, "CADUSD" => 1.1 })
    end
  end

  describe "#transaction" do
    let(:guard) { store.instance_variable_get(:@guard) }

    before do
      allow(guard).to receive(:synchronize)
    end

    it "uses mutex" do
      store.transaction { 1 + 1 }

      expect(guard).to have_received(:synchronize)
    end

    it "wraps block in mutex transaction only once" do
      expect do
        store.transaction do
          store.add_rate("USD", "CAD", 1)
        end
      end.not_to raise_error
    end
  end

  describe "#marshal_dump" do
    subject(:store) { described_class.new(optional: true) }

    it "can reload" do
      bank = Money::Bank::VariableExchange.new(store)
      bank = Marshal.load(Marshal.dump(bank))
      expect(bank.store.instance_variable_get(:@options)).to eq store.instance_variable_get(:@options)
      expect(bank.store.instance_variable_get(:@index)).to eq store.instance_variable_get(:@index)
    end
  end
end
