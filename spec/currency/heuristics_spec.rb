# encoding: utf-8

describe Money::Currency::Heuristics do
  describe "#analyze_string" do
    let(:it) { Money::Currency }

    it "is not affected by blank characters and numbers" do
      expect(it.analyze('123')).to eq []
      expect(it.analyze('\n123 \t')).to eq []
    end

    it "returns nothing when given nothing" do
      expect(it.analyze('')).to eq []
      expect(it.analyze(nil)).to eq []
    end

    it "finds a currency by use of its symbol" do
      expect(it.analyze('zł')).to eq ['PLN']
    end

    it "is not affected by trailing dot" do
      expect(it.analyze('zł.')).to eq ['PLN']
    end

    it "finds match even if has numbers after" do
      expect(it.analyze('zł 123')).to eq ['PLN']
    end

    it "finds match even if has numbers before" do
      expect(it.analyze('123 zł')).to eq ['PLN']
    end

    it "find match even if symbol is next to number" do
      expect(it.analyze('300zł')).to eq ['PLN']
    end

    it "finds match even if has numbers with delimiters" do
      expect(it.analyze('zł 123,000.50')).to eq ['PLN']
      expect(it.analyze('zł123,000.50')).to eq ['PLN']
    end

    it "finds currencies with dots in symbols" do
      expect(it.analyze('L.E.')).to eq ['EGP']
    end

    it "finds by name" do
      expect(it.analyze('1900 bulgarian lev')).to eq ['BGN']
      expect(it.analyze('Swedish Krona')).to eq ['SEK']
    end

    it "Finds several currencies when several match" do
      r = it.analyze('$400')
      expect(r).to include("ARS")
      expect(r).to include("USD")
      expect(r).to include("NZD")

      r = it.analyze('9000 £')
      expect(r).to include("GBP")
      expect(r).to include("SHP")
      expect(r).to include("SYP")
    end

    it "should use alternate symbols" do
      expect(it.analyze('US$')).to eq ['USD']
    end

    it "finds a currency by use of its iso code" do
      expect(it.analyze('USD 200')).to eq ['USD']
    end

    it "finds currencies in the middle of a sentence!" do
      expect(it.analyze('It would be nice to have 10000 Albanian lek by tomorrow!')).to eq ['ALL']
    end

    it "finds several currencies in the same text!" do
      expect(it.analyze("10EUR is less than 100:- but really, I want US$1")).to eq ['EUR', 'SEK', 'USD']
    end

    it "find currencies with normal characters in name using unaccent" do
      expect(it.analyze("10 Nicaraguan Cordoba")).to eq ["NIO"]
    end

    it "find currencies with special characters in name using unaccent" do
      expect(it.analyze("10 Nicaraguan Córdoba")).to eq ["NIO"]
    end

    it "find currencies with special symbols using unaccent" do
      expect(it.analyze("ل.س")).not_to eq []
      expect(it.analyze("R₣")).not_to eq []
      expect(it.analyze("ரூ")).not_to eq []
      expect(it.analyze("රු")).not_to eq []
      expect(it.analyze("сом")).not_to eq []
      expect(it.analyze("圓")).not_to eq []
      expect(it.analyze("円")).not_to eq []
      expect(it.analyze("৳")).not_to eq []
      expect(it.analyze("૱")).not_to eq []
      expect(it.analyze("௹")).not_to eq []
      expect(it.analyze("रु")).not_to eq []
      expect(it.analyze("ש״ח")).not_to eq []
      expect(it.analyze("元")).not_to eq []
      expect(it.analyze("¢")).not_to eq []
      expect(it.analyze("£")).not_to eq [] 
      expect(it.analyze("€")).not_to eq []
      expect(it.analyze("¥")).not_to eq []
      expect(it.analyze("د.إ")).not_to eq []
      expect(it.analyze("؋")).not_to eq []
      expect(it.analyze("դր.")).not_to eq []
      expect(it.analyze("ƒ")).not_to eq []
      expect(it.analyze("₼")).not_to eq []
      expect(it.analyze("৳")).not_to eq []
      expect(it.analyze("лв")).not_to eq []
      expect(it.analyze("лев")).not_to eq []
      expect(it.analyze("дин")).not_to eq []
      expect(it.analyze("ب.د")).not_to eq []
      expect(it.analyze("₡")).not_to eq []
      expect(it.analyze("Kč")).not_to eq []
      expect(it.analyze("د.ج")).not_to eq []
      expect(it.analyze("ج.م")).not_to eq []
      expect(it.analyze("ლ")).not_to eq []
      expect(it.analyze("₵")).not_to eq []
      expect(it.analyze("₪")).not_to eq []
      expect(it.analyze("₹")).not_to eq []
      expect(it.analyze("ع.د")).not_to eq []
      expect(it.analyze("﷼")).not_to eq []
      expect(it.analyze("د.ا")).not_to eq []
      expect(it.analyze("៛")).not_to eq []
      expect(it.analyze("₩")).not_to eq []
      expect(it.analyze("د.ك")).not_to eq []
      expect(it.analyze("〒")).not_to eq []
      expect(it.analyze("₭")).not_to eq []
      expect(it.analyze("ل.ل")).not_to eq []
      expect(it.analyze("₨")).not_to eq []
      expect(it.analyze("ل.د")).not_to eq []
      expect(it.analyze("د.م.")).not_to eq []
      expect(it.analyze("ден")).not_to eq []
      expect(it.analyze("₮")).not_to eq []
      expect(it.analyze("₦")).not_to eq []
      expect(it.analyze("C$")).not_to eq []
      expect(it.analyze("ر.ع.")).not_to eq []
      expect(it.analyze("₱")).not_to eq []
      expect(it.analyze("zł")).not_to eq []
      expect(it.analyze("₲")).not_to eq []
      expect(it.analyze("ر.ق")).not_to eq []
      expect(it.analyze("РСД")).not_to eq []
      expect(it.analyze("₽")).not_to eq []
      expect(it.analyze("ر.س")).not_to eq []
      expect(it.analyze("฿")).not_to eq []
      expect(it.analyze("د.ت")).not_to eq []
      expect(it.analyze("T$")).not_to eq []
      expect(it.analyze("₺")).not_to eq []
      expect(it.analyze("₴")).not_to eq []
      expect(it.analyze("₫")).not_to eq []
      expect(it.analyze("B⃦")).not_to eq []
      expect(it.analyze("₤")).not_to eq []
      expect(it.analyze("ރ")).not_to eq []
    end

    it "should function with unicode characters" do
      expect(it.analyze("10 դր.")).to eq ["AMD"]
    end
  end
end
