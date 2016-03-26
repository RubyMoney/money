describe Money do
  describe "#to_s" do
    it "works as documented" do
      expect(Money.new(10_00).to_s).to eq "10.00"
      expect(Money.new(400_08).to_s).to eq "400.08"
      expect(Money.new(-237_43).to_s).to eq "-237.43"
    end

    it "respects :subunit_to_unit currency property" do
      expect(Money.new(10_00, "BHD").to_s).to eq "1.000"
      expect(Money.new(10_00, "CNY").to_s).to eq "10.00"
    end

    it "does not have decimal when :subunit_to_unit == 1" do
      expect(Money.new(10_00, "VUV").to_s).to eq "1000"
    end

    it "does not work when :subunit_to_unit == 5" do
      expect(Money.new(10_00, "MGA").to_s).to eq "200.0"
    end

    it "respects :decimal_mark" do
      expect(Money.new(10_00, "BRL").to_s).to eq "10,00"
    end

    context "with infinite_precision", :infinite_precision do
      it "shows fractional cents" do
        expect(Money.new(1.05, "USD").to_s).to eq "0.0105"
      end

      it "suppresses fractional cents when there is none" do
        expect(Money.new(1.0, "USD").to_s).to eq "0.01"
      end

      it "shows fractional if needed when :subunut_to_unit == 1" do
        expect(Money.new(10_00.1, "VUV").to_s).to eq "1000.1"
      end
    end
  end
end
