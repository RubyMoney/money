# encoding: utf-8

describe Money::Currency do
  FOO = '{ "priority": 1, "iso_code": "FOO", "iso_numeric": "840", "name": "United States Dollar", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 1000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "smallest_denomination": 1 }'

  def register_foo(opts={})
    foo_attrs = JSON.parse(FOO, symbolize_names: true)
    # Pass an array of attribute names to 'skip' to remove them from the 'FOO'
    # json before registering foo as a currency.
    Array(opts[:skip]).each { |attr| foo_attrs.delete(attr) }
    described_class.register(foo_attrs)
  end

  def unregister_foo
    described_class.unregister(JSON.parse(FOO, symbolize_names: true))
  end

  describe "UnknownCurrency" do
    it "is a subclass of ArgumentError" do
      expect(described_class::UnknownCurrency < ArgumentError).to be true
    end
  end

  describe ".find" do
    before { register_foo }
    after  { unregister_foo }

    it "returns currency matching given id" do
      expected = described_class.new(:foo)
      expect(described_class.find(:foo)).to be  expected
      expect(described_class.find(:FOO)).to be  expected
      expect(described_class.find("foo")).to be expected
      expect(described_class.find("FOO")).to be expected
    end

    it "returns nil unless currency matching given id" do
      expect(described_class.find("ZZZ")).to be_nil
    end
  end

  describe ".find_by_iso_numeric" do
    it "returns currency matching given numeric code" do
      expect(described_class.find_by_iso_numeric(978)).to eq     described_class.new(:eur)
      expect(described_class.find_by_iso_numeric(208)).not_to eq described_class.new(:eur)
      expect(described_class.find_by_iso_numeric('840')).to eq   described_class.new(:usd)
      expect(described_class.find_by_iso_numeric(51)).to eq described_class.new(:amd)

      class Mock
        def to_s
          '208'
        end
      end
      expect(described_class.find_by_iso_numeric(Mock.new)).to eq     described_class.new(:dkk)
      expect(described_class.find_by_iso_numeric(Mock.new)).not_to eq described_class.new(:usd)
    end

    it "returns nil if no currency has the given numeric code" do
      expect(described_class.find_by_iso_numeric('non iso 4217 numeric code')).to be_nil
      expect(described_class.find_by_iso_numeric(0)).to be_nil
    end

    it "returns nil when given empty input" do
      expect(described_class.find_by_iso_numeric('')).to be_nil
      expect(described_class.find_by_iso_numeric(nil)).to be_nil
    end
  end

  describe ".wrap" do
    it "returns nil if object is nil" do
      expect(described_class.wrap(nil)).to be_nil
      expect(described_class.wrap(described_class.new(:usd))).to eq described_class.new(:usd)
      expect(described_class.wrap(:usd)).to eq described_class.new(:usd)
    end
  end

  describe ".all" do
    it "returns an array of currencies" do
      expect(described_class.all).to include described_class.new(:usd)
    end
    it "includes registered currencies" do
      register_foo
      expect(described_class.all).to include described_class.new(:foo)
      unregister_foo
    end
    it 'is sorted by priority' do
      expect(described_class.all.first.priority).to eq 1
    end
    it "raises a MissingAttributeError if any currency has no priority" do
      register_foo(skip: :priority)

      expect{described_class.all}.to \
        raise_error(described_class::MissingAttributeError, /foo.*priority/)
      unregister_foo
    end
  end


  describe ".register" do
    after { described_class.unregister(iso_code: "XXX") if described_class.find("XXX") }

    it "registers a new currency" do
      described_class.register(
        iso_code: "XXX",
        name: "Golden Doubloon",
        symbol: "%",
        subunit_to_unit: 100
      )
      new_currency = described_class.find("XXX")
      expect(new_currency).not_to be_nil
      expect(new_currency.name).to eq "Golden Doubloon"
      expect(new_currency.symbol).to eq "%"
    end

    specify ":iso_code must be present" do
      expect {
        described_class.register(name: "New Currency")
      }.to raise_error(KeyError)
    end
  end


  describe ".inherit" do
    after do
      described_class.unregister(iso_code: "XXX") if described_class.find("XXX")
      described_class.unregister(iso_code: "YYY") if described_class.find("YYY")
    end

    it "inherit a new currency" do
      described_class.register(
        iso_code: "XXX",
        name: "Golden Doubloon",
        symbol: "%",
        subunit_to_unit: 100
      )
      described_class.inherit("XXX",
        iso_code: "YYY",
        symbol: "@"
      )
      new_currency = described_class.find("YYY")
      expect(new_currency).not_to be_nil
      expect(new_currency.name).to eq "Golden Doubloon"
      expect(new_currency.symbol).to eq "@"
      expect(new_currency.subunit_to_unit).to eq 100
    end
  end


  describe ".unregister" do
    it "unregisters a currency" do
      described_class.register(iso_code: "XXX")
      expect(described_class.find("XXX")).not_to be_nil # Sanity check
      described_class.unregister(iso_code: "XXX")
      expect(described_class.find("XXX")).to be_nil
    end

    it "returns true iff the currency existed" do
      described_class.register(iso_code: "XXX")
      expect(described_class.unregister(iso_code: "XXX")).to be_truthy
      expect(described_class.unregister(iso_code: "XXX")).to be_falsey
    end

    it "can be passed an ISO code" do
      described_class.register(iso_code: "XXX")
      described_class.register(iso_code: "YYZ")
      # Test with string:
      described_class.unregister("XXX")
      expect(described_class.find("XXX")).to be_nil
      # Test with symbol:
      described_class.unregister(:yyz)
      expect(described_class.find(:yyz)).to be_nil
    end
  end


  describe ".each" do
    it "yields each currency to the block" do
      expect(described_class).to respond_to(:each)
      currencies = []
      described_class.each do |currency|
        currencies.push(currency)
      end

      # Don't bother testing every single currency
      expect(currencies[0]).to eq described_class.all[0]
      expect(currencies[1]).to eq described_class.all[1]
      expect(currencies[-1]).to eq described_class.all[-1]
    end
  end


  it "implements Enumerable" do
    expect(described_class).to respond_to(:all?)
    expect(described_class).to respond_to(:each_with_index)
    expect(described_class).to respond_to(:map)
    expect(described_class).to respond_to(:select)
    expect(described_class).to respond_to(:reject)
  end


  describe "#initialize" do
    before { described_class._instances.clear }

    it "lookups data from loaded config" do
      currency = described_class.new("USD")
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

    it 'caches instances' do
      currency = described_class.new("USD")

      expect(described_class._instances.length).to           eq 1
      expect(described_class._instances["usd"].object_id).to eq currency.object_id
    end

    it "raises UnknownCurrency with unknown currency" do
      expect { described_class.new("xxx") }.to raise_error(described_class::UnknownCurrency, /xxx/)
    end

    it 'returns old object for the same :key' do
      expect(described_class.new("USD")).to be(described_class.new("USD"))
      expect(described_class.new("USD")).to be(described_class.new(:usd))
      expect(described_class.new("USD")).to be(described_class.new(:USD))
      expect(described_class.new("USD")).to be(described_class.new('usd'))
      expect(described_class.new("USD")).to be(described_class.new('Usd'))
    end

    it 'returns new object for the different :key' do
      expect(described_class.new("USD")).to_not be(described_class.new("EUR"))
    end

    it 'is thread safe' do
      ids = []
      2.times.map{ Thread.new{ ids << described_class.new("USD").object_id }}.each(&:join)
      expect(ids.uniq.length).to eq(1)
    end
  end

  describe "#<=>" do
    it "compares objects by priority" do
      expect(described_class.new(:cad)).to be > described_class.new(:usd)
      expect(described_class.new(:usd)).to be < described_class.new(:eur)
    end

    it "compares by id when priority is the same" do
      described_class.register(iso_code: "ABD", priority: 15)
      described_class.register(iso_code: "ABC", priority: 15)
      described_class.register(iso_code: "ABE", priority: 15)
      abd = described_class.find("ABD")
      abc = described_class.find("ABC")
      abe = described_class.find("ABE")
      expect(abd).to be > abc
      expect(abe).to be > abd
      described_class.unregister("ABD")
      described_class.unregister("ABC")
      described_class.unregister("ABE")
    end

    context "when one of the currencies has no 'priority' set" do
      it "compares by id" do
        described_class.register(iso_code: "ABD") # No priority
        abd = described_class.find(:abd)
        usd = described_class.find(:usd)
        expect(abd).to be < usd
        described_class.unregister(iso_code: "ABD")
      end
    end
  end

  describe "#==" do
    it "returns true if self === other" do
      currency = described_class.new(:eur)
      expect(currency).to eq currency
    end

    it "returns true if the id is equal ignorning case" do
      expect(described_class.new(:eur)).to     eq described_class.new(:eur)
      expect(described_class.new(:eur)).to     eq described_class.new(:EUR)
      expect(described_class.new(:eur)).not_to eq described_class.new(:usd)
    end

    it "allows direct comparison of currencies and symbols/strings" do
      expect(described_class.new(:eur)).to     eq 'eur'
      expect(described_class.new(:eur)).to     eq 'EUR'
      expect(described_class.new(:eur)).to     eq :eur
      expect(described_class.new(:eur)).to     eq :EUR
      expect(described_class.new(:eur)).not_to eq 'usd'
    end

    it "allows comparison with nil and returns false" do
      expect(described_class.new(:eur)).not_to be_nil
    end
  end

  describe "#eql?" do
    it "returns true if #== returns true" do
      expect(described_class.new(:eur).eql?(described_class.new(:eur))).to be true
      expect(described_class.new(:eur).eql?(described_class.new(:usd))).to be false
    end
  end

  describe "#hash" do
    it "returns the same value for equal objects" do
      expect(described_class.new(:eur).hash).to eq described_class.new(:eur).hash
      expect(described_class.new(:eur).hash).not_to eq described_class.new(:usd).hash
    end

    it "can be used to return the intersection of Currency object arrays" do
      intersection = [described_class.new(:eur), described_class.new(:usd)] & [described_class.new(:eur)]
      expect(intersection).to eq [described_class.new(:eur)]
    end
  end

  describe "#inspect" do
    it "works as documented" do
      expect(described_class.new(:usd).inspect).to eq %Q{#<Money::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, exponent: 2, iso_code: USD, iso_numeric: 840, subunit: Cent, smallest_denomination: 1>}
    end
  end

  describe "#iso?" do
    it "returns true for iso currency" do
      expect(described_class.new(:eur).iso?).to be true
    end

    it "returns false if the currency is not iso" do
      expect(described_class.new(:btc).iso?).to be false
    end
  end

  describe "#to_s" do
    it "works as documented" do
      expect(described_class.new(:usd).to_s).to eq("USD")
      expect(described_class.new(:eur).to_s).to eq("EUR")
    end
  end

  describe "#to_str" do
    it "works as documented" do
      expect(described_class.new(:usd).to_str).to eq("USD")
      expect(described_class.new(:eur).to_str).to eq("EUR")
    end
  end

  describe "#to_sym" do
    it "works as documented" do
      expect(described_class.new(:usd).to_sym).to eq(:USD)
      expect(described_class.new(:eur).to_sym).to eq(:EUR)
    end
  end

  describe "#to_currency" do
    it "works as documented" do
      usd = described_class.new(:usd)
      expect(usd.to_currency).to eq usd
    end

    it "doesn't create new symbols indefinitely" do
      expect { described_class.new("bogus") }.to raise_exception(described_class::UnknownCurrency)
      expect(Symbol.all_symbols.map{|s| s.to_s}).not_to include("bogus")
    end
  end

  describe "#code" do
    it "works as documented" do
      expect(described_class.new(:usd).code).to eq "$"
      expect(described_class.new(:azn).code).to eq "\u20BC"
    end
  end

  describe "#exponent" do
    it "conforms to iso 4217" do
      expect(described_class.new(:jpy).exponent).to eq 0
      expect(described_class.new(:usd).exponent).to eq 2
      expect(described_class.new(:iqd).exponent).to eq 3
    end
  end

  describe "#decimal_places" do
    it "proper places for known currency" do
      expect(described_class.new(:mru).decimal_places).to eq 1
      expect(described_class.new(:usd).decimal_places).to eq 2
    end

    it "proper places for custom currency" do
      register_foo
      expect(described_class.new(:foo).decimal_places).to eq 3
      unregister_foo
    end
  end
end
