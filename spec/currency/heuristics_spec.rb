# encoding: utf-8

describe Money::Currency::Heuristics do
  describe "#analyze_string" do
    let(:it) { Money::Currency }

    it "it raises deprecation error" do
      expect{ it.analyze('123') }.to raise_error(StandardError, 'Heuristics deprecated, add `gem "money-heuristics"` to Gemfile')
    end
  end
end
