# encoding: utf-8

require "spec_helper"

describe Money::Currency do

  FOO = '{ "priority": 1, "iso_code": "FOO", "iso_numeric": "840", "name": "United States Dollar", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 450, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "smallest_denomination": 1 }'

  def register_foo
    Money::Currency.register(JSON.parse(FOO, :symbolize_names => true))
  end

  def unregister_foo
    Money::Currency.unregister(JSON.parse(FOO, :symbolize_names => true))
  end

  describe "UnknownMoney::Currency" do
    it "is a subclass of ArgumentError" do
      expect(Money::Currency::UnknownCurrency < ArgumentError).to be true
    end
  end

  describe ".find" do
    before { register_foo }
    after  { unregister_foo }

    it "returns currency matching given id" do
      expected = Money::Currency.new(:foo)
      expect(Money::Currency.find(:foo)).to eq  expected
      expect(Money::Currency.find(:FOO)).to eq  expected
      expect(Money::Currency.find("foo")).to eq expected
      expect(Money::Currency.find("FOO")).to eq expected
    end

    it "returns nil unless currency matching given id" do
      expect(Money::Currency.find("ZZZ")).to be_nil
    end
  end

  describe ".find_by_iso_numeric" do
    it "returns currency matching given numeric code" do
      expect(Money::Currency.find_by_iso_numeric(978)).to eq          Money::Currency.new(:eur)
      expect(Money::Currency.find_by_iso_numeric(208)).not_to eq      Money::Currency.new(:eur)
      expect(Money::Currency.find_by_iso_numeric('840')).to eq        Money::Currency.new(:usd)

      class Mock
        def to_s
          '208'
        end
      end
      expect(Money::Currency.find_by_iso_numeric(Mock.new)).to eq     Money::Currency.new(:dkk)
      expect(Money::Currency.find_by_iso_numeric(Mock.new)).not_to eq Money::Currency.new(:usd)
    end

    it "returns nil if no currency has the given numeric code" do
      expect(Money::Currency.find_by_iso_numeric('non iso 4217 numeric code')).to be_nil
      expect(Money::Currency.find_by_iso_numeric(0)).to be_nil
    end
  end

  describe ".wrap" do
    it "returns nil if object is nil" do
      expect(Money::Currency.wrap(nil)).to be_nil
      expect(Money::Currency.wrap(Money::Currency.new(:usd))).to eq Money::Currency.new(:usd)
      expect(Money::Currency.wrap(:usd)).to eq Money::Currency.new(:usd)
    end
  end

  describe ".all" do
    it "returns an array of currencies" do
      expect(Money::Currency.all).to include Money::Currency.new(:usd)
    end
    it "includes registered currencies" do
      register_foo
      expect(Money::Currency.all).to include Money::Currency.new(:foo)
      unregister_foo
    end
    it 'is sorted by priority' do
      expect(Money::Currency.all.first.priority).to eq 1
    end
  end


  describe ".register" do
    after { Money::Currency.unregister(iso_code: "XXX") if Money::Currency.find("XXX") }

    it "registers a new currency" do
      Money::Currency.register(
        iso_code: "XXX",
        name: "Golden Doubloon",
        symbol: "%",
        subunit_to_unit: 100
      )
      new_currency = Money::Currency.find("XXX")
      expect(new_currency).not_to be_nil
      expect(new_currency.name).to eq "Golden Doubloon"
      expect(new_currency.symbol).to eq "%"
    end

    specify ":iso_code must be present" do
      expect {
        Money::Currency.register(name: "New Currency")
      }.to raise_error(KeyError)
    end
  end


  describe ".unregister" do
    it "unregisters a currency" do
      Money::Currency.register(iso_code: "XXX")
      expect(Money::Currency.find("XXX")).not_to be_nil # Sanity check
      Money::Currency.unregister(iso_code: "XXX")
      expect(Money::Currency.find("XXX")).to be_nil
    end

    it "returns true iff the currency existed" do
      Money::Currency.register(iso_code: "XXX")
      expect(Money::Currency.unregister(iso_code: "XXX")).to be_truthy
      expect(Money::Currency.unregister(iso_code: "XXX")).to be_falsey
    end

    it "can be passed an ISO code" do
      Money::Currency.register(iso_code: "XXX")
      Money::Currency.register(iso_code: "YYZ")
      # Test with string:
      Money::Currency.unregister("XXX")
      expect(Money::Currency.find("XXX")).to be_nil
      # Test with symbol:
      Money::Currency.unregister(:yyz)
      expect(Money::Currency.find(:yyz)).to be_nil
    end
  end


  describe ".each" do
    it "yields each currency to the block" do
      expect(Money::Currency).to respond_to(:each)
      currencies = []
      Money::Currency.each do |currency|
        currencies.push(currency)
      end

      # Don't bother testing every single currency
      expect(currencies[0]).to eq Money::Currency.all[0]
      expect(currencies[1]).to eq Money::Currency.all[1]
      expect(currencies[-1]).to eq Money::Currency.all[-1]
    end
  end


  it "implements Enumerable" do
    expect(Money::Currency).to respond_to(:all?)
    expect(Money::Currency).to respond_to(:each_with_index)
    expect(Money::Currency).to respond_to(:map)
    expect(Money::Currency).to respond_to(:select)
    expect(Money::Currency).to respond_to(:reject)
  end


  describe "#initialize" do
    it "lookups data from loaded config" do
      currency = Money::Currency.new("USD")
      expect(currency.id).to                    eq :usd
      expect(currency.priority).to              eq 1
      expect(currency.iso_code).to              eq "USD"
      expect(currency.iso_numeric).to           eq "840"
      expect(currency.name).to                  eq "United States Dollar"
      expect(currency.decimal_mark).to          eq "."
      expect(currency.separator).to             eq "."
      expect(currency.thousands_separator).to   eq ","
      expect(currency.delimiter).to             eq ","
      expect(currency.smallest_denomination).to eq 1
    end

    it "raises UnknownMoney::Currency with unknown currency" do
      expect { Money::Currency.new("xxx") }.to raise_error(Money::Currency::UnknownCurrency, /xxx/)
    end
  end

  describe "#<=>" do
    it "compares objects by priority" do
      expect(Money::Currency.new(:cad)).to be > Money::Currency.new(:usd)
      expect(Money::Currency.new(:usd)).to be < Money::Currency.new(:eur)
    end

    it "compares by id when priority is the same" do
      Money::Currency.register(iso_code: "ABD", priority: 15)
      Money::Currency.register(iso_code: "ABC", priority: 15)
      Money::Currency.register(iso_code: "ABE", priority: 15)
      abd = Money::Currency.find("ABD")
      abc = Money::Currency.find("ABC")
      abe = Money::Currency.find("ABE")
      expect(abd).to be > abc
      expect(abe).to be > abd
      Money::Currency.unregister("ABD")
      Money::Currency.unregister("ABC")
      Money::Currency.unregister("ABE")
    end

    context "when one of the currencies has no 'priority' set" do
      it "compares by id" do
        Money::Currency.register(iso_code: "ABD") # No priority
        abd = Money::Currency.find(:abd)
        usd = Money::Currency.find(:usd)
        expect(abd).to be < usd
        Money::Currency.unregister(iso_code: "ABD")
      end
    end
  end

  describe "#==" do
    it "returns true if self === other" do
      currency = Money::Currency.new(:eur)
      expect(currency).to eq currency
    end

    it "returns true if the id is equal ignorning case" do
      expect(Money::Currency.new(:eur)).to     eq Money::Currency.new(:eur)
      expect(Money::Currency.new(:eur)).to     eq Money::Currency.new(:EUR)
      expect(Money::Currency.new(:eur)).not_to eq Money::Currency.new(:usd)
    end

    it "allows direct comparison of currencies and symbols/strings" do
      expect(Money::Currency.new(:eur)).to     eq 'eur'
      expect(Money::Currency.new(:eur)).to     eq 'EUR'
      expect(Money::Currency.new(:eur)).to     eq :eur
      expect(Money::Currency.new(:eur)).to     eq :EUR
      expect(Money::Currency.new(:eur)).not_to eq 'usd'
    end

    it "allows comparison with nil and returns false" do
      expect(Money::Currency.new(:eur)).not_to be_nil
    end
  end

  describe "#eql?" do
    it "returns true if #== returns true" do
      expect(Money::Currency.new(:eur).eql?(Money::Currency.new(:eur))).to be true
      expect(Money::Currency.new(:eur).eql?(Money::Currency.new(:usd))).to be false
    end
  end

  describe "#hash" do
    it "returns the same value for equal objects" do
      expect(Money::Currency.new(:eur).hash).to eq Money::Currency.new(:eur).hash
      expect(Money::Currency.new(:eur).hash).not_to eq Money::Currency.new(:usd).hash
    end

    it "can be used to return the intersection of Currency object arrays" do
      intersection = [Money::Currency.new(:eur), Money::Currency.new(:usd)] & [Money::Currency.new(:eur)]
      expect(intersection).to eq [Money::Currency.new(:eur)]
    end
  end

  describe "#inspect" do
    it "works as documented" do
      expect(Money::Currency.new(:usd).inspect).to eq %Q{#<Money::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, exponent: 2.0, iso_code: USD, iso_numeric: 840, subunit: Cent, smallest_denomination: 1>}
    end
  end

  describe "#to_s" do
    it "works as documented" do
      expect(Money::Currency.new(:usd).to_s).to eq("USD")
      expect(Money::Currency.new(:eur).to_s).to eq("EUR")
    end
  end

  describe "#to_str" do
    it "works as documented" do
      expect(Money::Currency.new(:usd).to_str).to eq("USD")
      expect(Money::Currency.new(:eur).to_str).to eq("EUR")
    end
  end

  describe "#to_sym" do
    it "works as documented" do
      expect(Money::Currency.new(:usd).to_sym).to eq(:USD)
      expect(Money::Currency.new(:eur).to_sym).to eq(:EUR)
    end
  end

  describe "#to_currency" do
    it "works as documented" do
      usd = Money::Currency.new(:usd)
      expect(usd.to_currency).to eq usd
    end

    it "doesn't create new symbols indefinitely" do
      expect { Money::Currency.new("bogus") }.to raise_exception(Money::Currency::UnknownCurrency)
      expect(Symbol.all_symbols.map{|s| s.to_s}).not_to include("bogus")
    end
  end

  describe "#code" do
    it "works as documented" do
      expect(Money::Currency.new(:usd).code).to eq "$"
      expect(Money::Currency.new(:azn).code).to eq "\u20BC"
    end
  end

  describe "#exponent" do
    it "conforms to iso 4217" do
      Money::Currency.new(:jpy).exponent == 0
      Money::Currency.new(:usd).exponent == 2
      Money::Currency.new(:iqd).exponent == 3
    end
  end

  describe "#decimal_places" do
    it "proper places for known currency" do
      Money::Currency.new(:mro).decimal_places == 1
      Money::Currency.new(:usd).decimal_places == 2
    end

    it "proper places for custom currency" do
      register_foo
      Money::Currency.new(:foo).decimal_places == 3
      unregister_foo
    end
  end
end
