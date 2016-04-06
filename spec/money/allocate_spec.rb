describe Money do
  describe "#allocate" do
    it "takes no action when one gets all" do
      expect(Money.usd(0.05).allocate([1.0])).to eq [Money.usd(0.05)]
    end

    it "keeps currencies intact" do
      expect(Money.ca_dollar(0.05).allocate([1])).to eq [Money.ca_dollar(0.05)]
    end

    it "does not lose pennies" do
      moneys = Money.usd(0.05).allocate([0.3, 0.7])
      expect(moneys).to eq [Money.usd(0.02), Money.usd(0.03)]
    end

    it "does not lose pennies" do
      moneys = Money.usd(1).allocate([0.333, 0.333, 0.333])
      expect(moneys.map(&:to_d)).to eq [0.34, 0.33, 0.33]
    end

    it "requires total to be less then 1" do
      expect { Money.usd(0.05).allocate([0.5, 0.6]) }.to raise_error(ArgumentError)
    end

    it "keeps subclasses intact" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(0.05).allocate([1]).first).to be_a special_money_class
    end

    context "with infinite_precision", :infinite_precision do
      it "allows for fractional cents allocation" do
        moneys = Money.new(1).allocate([1.to_d / 3] * 3)
        expect(moneys.map(&:to_d)).to eq([1.to_d / 3] * 3)
      end
    end
  end

  describe "#split" do
    it "needs at least one party" do
      expect { Money.usd(1).split(0) }.to raise_error(ArgumentError)
      expect { Money.usd(1).split(-1) }.to raise_error(ArgumentError)
    end

    it "gives 1 cent to both people if we start with 2" do
      expect(Money.usd(0.02).split(2)).to eq [Money.usd(0.01), Money.usd(0.01)]
    end

    it "may distribute no money to some parties if there isnt enough to go around" do
      expect(Money.usd(0.02).split(3)).to eq [Money.usd(0.01), Money.usd(0.01), Money.usd(0)]
    end

    it "does not lose pennies" do
      expect(Money.usd(0.05).split(2)).to eq [Money.usd(0.03), Money.usd(0.02)]
    end

    it "splits a dollar" do
      moneys = Money.usd(1).split(3)
      expect(moneys.map(&:to_d)).to eq [0.34, 0.33, 0.33]
    end

    it "preserves the class in the result when using a subclass of Money" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(10_00).split(1).first).to be_a special_money_class
    end

    context "with infinite_precision", :infinite_precision do
      it "allows for splitting by fractional cents" do
        moneys = Money.new(1).split(3)
        expect(moneys.map(&:to_d)).to eq([1.to_d / 3] * 3)
      end
    end
  end
end
