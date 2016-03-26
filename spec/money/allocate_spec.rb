describe Money do
  describe "#allocate" do
    it "takes no action when one gets all" do
      expect(Money.us_dollar(005).allocate([1.0])).to eq [Money.us_dollar(5)]
    end

    it "keeps currencies intact" do
      expect(Money.ca_dollar(005).allocate([1])).to eq [Money.ca_dollar(5)]
    end

    it "does not lose pennies" do
      moneys = Money.us_dollar(5).allocate([0.3, 0.7])
      expect(moneys[0]).to eq Money.us_dollar(2)
      expect(moneys[1]).to eq Money.us_dollar(3)
    end

    it "does not lose pennies" do
      moneys = Money.us_dollar(100).allocate([0.333, 0.333, 0.333])
      expect(moneys[0].cents).to eq 34
      expect(moneys[1].cents).to eq 33
      expect(moneys[2].cents).to eq 33
    end

    it "requires total to be less then 1" do
      expect { Money.us_dollar(0.05).allocate([0.5, 0.6]) }.to raise_error(ArgumentError)
    end

    it "keeps subclasses intact" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(005).allocate([1]).first).to be_a special_money_class
    end

    context "with infinite_precision", :infinite_precision do
      it "allows for fractional cents allocation" do
        one_third = BigDecimal("1") / BigDecimal("3")

        moneys = Money.new(100).allocate([one_third, one_third, one_third])
        expect(moneys[0].cents).to eq one_third * BigDecimal("100")
        expect(moneys[1].cents).to eq one_third * BigDecimal("100")
        expect(moneys[2].cents).to eq one_third * BigDecimal("100")
      end
    end
  end

  describe "#split" do
    it "needs at least one party" do
      expect { Money.us_dollar(1).split(0) }.to raise_error(ArgumentError)
      expect { Money.us_dollar(1).split(-1) }.to raise_error(ArgumentError)
    end

    it "gives 1 cent to both people if we start with 2" do
      expect(Money.us_dollar(2).split(2)).to eq [Money.us_dollar(1), Money.us_dollar(1)]
    end

    it "may distribute no money to some parties if there isnt enough to go around" do
      expect(Money.us_dollar(2).split(3)).to eq [Money.us_dollar(1), Money.us_dollar(1), Money.us_dollar(0)]
    end

    it "does not lose pennies" do
      expect(Money.us_dollar(5).split(2)).to eq [Money.us_dollar(3), Money.us_dollar(2)]
    end

    it "splits a dollar" do
      moneys = Money.us_dollar(100).split(3)
      expect(moneys[0].cents).to eq 34
      expect(moneys[1].cents).to eq 33
      expect(moneys[2].cents).to eq 33
    end

    it "preserves the class in the result when using a subclass of Money" do
      special_money_class = Class.new(Money)
      expect(special_money_class.new(10_00).split(1).first).to be_a special_money_class
    end

    context "with infinite_precision", :infinite_precision do
      it "allows for splitting by fractional cents" do
        thirty_three_and_one_third = BigDecimal("100") / BigDecimal("3")

        moneys = Money.new(100).split(3)
        expect(moneys[0].cents).to eq thirty_three_and_one_third
        expect(moneys[1].cents).to eq thirty_three_and_one_third
        expect(moneys[2].cents).to eq thirty_three_and_one_third
      end
    end
  end
end
