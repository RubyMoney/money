# encoding: utf-8

class Money
  describe Currency do

    FOO = '{ "priority": 1, "iso_code": "FOO", "iso_numeric": "840", "name": "United States Dollar", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 1000, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "smallest_denomination": 1 }'

    def register_foo(opts={})
      foo_attrs = JSON.parse(FOO, :symbolize_names => true)
      # Pass an array of attribute names to 'skip' to remove them from the 'FOO'
      # json before registering foo as a currency.
      Array(opts[:skip]).each { |attr| foo_attrs.delete(attr) }
      Money::Currency.register(foo_attrs)
    end

    def unregister_foo
      Currency.unregister(JSON.parse(FOO, :symbolize_names => true))
    end

    describe "UnknownCurrency" do
      it "is a subclass of ArgumentError" do
        expect(Currency::UnknownCurrency < ArgumentError).to be true
      end
    end

    describe ".find" do
      before { register_foo }
      after  { unregister_foo }

      it "returns currency matching given id" do
        expected = Currency.new(:foo)
        expect(Currency.find(:foo)).to be  expected
        expect(Currency.find(:FOO)).to be  expected
        expect(Currency.find("foo")).to be expected
        expect(Currency.find("FOO")).to be expected
      end

      it "returns nil unless currency matching given id" do
        expect(Currency.find("ZZZ")).to be_nil
      end
    end

    describe ".find_by_iso_numeric" do
      it "returns currency matching given numeric code" do
        expect(Currency.find_by_iso_numeric(978)).to eq     Currency.new(:eur)
        expect(Currency.find_by_iso_numeric(208)).not_to eq Currency.new(:eur)
        expect(Currency.find_by_iso_numeric('840')).to eq   Currency.new(:usd)

        class Mock
          def to_s
            '208'
          end
        end
        expect(Currency.find_by_iso_numeric(Mock.new)).to eq     Currency.new(:dkk)
        expect(Currency.find_by_iso_numeric(Mock.new)).not_to eq Currency.new(:usd)
      end

      it "returns nil if no currency has the given numeric code" do
        expect(Currency.find_by_iso_numeric('non iso 4217 numeric code')).to be_nil
        expect(Currency.find_by_iso_numeric(0)).to be_nil
      end
    end

    describe ".wrap" do
      it "returns nil if object is nil" do
        expect(Currency.wrap(nil)).to be_nil
        expect(Currency.wrap(Currency.new(:usd))).to eq Currency.new(:usd)
        expect(Currency.wrap(:usd)).to eq Currency.new(:usd)
      end
    end

    describe ".all" do
      it "returns an array of currencies" do
        expect(Currency.all).to include Currency.new(:usd)
      end
      it "includes registered currencies" do
        register_foo
        expect(Currency.all).to include Currency.new(:foo)
        unregister_foo
      end
      it 'is sorted by priority' do
        expect(Currency.all.first.priority).to eq 1
      end
      it "raises a MissingAttributeError if any currency has no priority" do
        register_foo(:skip => :priority)

        expect{Money::Currency.all}.to \
          raise_error(Money::Currency::MissingAttributeError, /foo.*priority/)
        unregister_foo
      end
    end


    describe ".register" do
      after { Currency.unregister(iso_code: "XXX") if Currency.find("XXX") }

      it "registers a new currency" do
        Currency.register(
          iso_code: "XXX",
          name: "Golden Doubloon",
          symbol: "%",
          subunit_to_unit: 100
        )
        new_currency = Currency.find("XXX")
        expect(new_currency).not_to be_nil
        expect(new_currency.name).to eq "Golden Doubloon"
        expect(new_currency.symbol).to eq "%"
      end

      specify ":iso_code must be present" do
        expect {
          Currency.register(name: "New Currency")
        }.to raise_error(KeyError)
      end
    end


    describe ".unregister" do
      it "unregisters a currency" do
        Currency.register(iso_code: "XXX")
        expect(Currency.find("XXX")).not_to be_nil # Sanity check
        Currency.unregister(iso_code: "XXX")
        expect(Currency.find("XXX")).to be_nil
      end

      it "returns true iff the currency existed" do
        Currency.register(iso_code: "XXX")
        expect(Currency.unregister(iso_code: "XXX")).to be_truthy
        expect(Currency.unregister(iso_code: "XXX")).to be_falsey
      end

      it "can be passed an ISO code" do
        Currency.register(iso_code: "XXX")
        Currency.register(iso_code: "YYZ")
        # Test with string:
        Currency.unregister("XXX")
        expect(Currency.find("XXX")).to be_nil
        # Test with symbol:
        Currency.unregister(:yyz)
        expect(Currency.find(:yyz)).to be_nil
      end
    end


    describe ".each" do
      it "yields each currency to the block" do
        expect(Currency).to respond_to(:each)
        currencies = []
        Currency.each do |currency|
          currencies.push(currency)
        end

        # Don't bother testing every single currency
        expect(currencies[0]).to eq Currency.all[0]
        expect(currencies[1]).to eq Currency.all[1]
        expect(currencies[-1]).to eq Currency.all[-1]
      end
    end


    it "implements Enumerable" do
      expect(Currency).to respond_to(:all?)
      expect(Currency).to respond_to(:each_with_index)
      expect(Currency).to respond_to(:map)
      expect(Currency).to respond_to(:select)
      expect(Currency).to respond_to(:reject)
    end


    describe "#initialize" do
      before { Currency._instances.clear }

      it "lookups data from loaded config" do
        currency = Currency.new("USD")
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
        currency = Currency.new("USD")

        expect(Currency._instances.length).to           eq 1
        expect(Currency._instances["usd"].object_id).to eq currency.object_id
      end

      it "raises UnknownCurrency with unknown currency" do
        expect { Currency.new("xxx") }.to raise_error(Currency::UnknownCurrency, /xxx/)
      end

      it 'returns old object for the same :key' do
        expect(Currency.new("USD")).to be(Currency.new("USD"))
        expect(Currency.new("USD")).to be(Currency.new(:usd))
        expect(Currency.new("USD")).to be(Currency.new(:USD))
        expect(Currency.new("USD")).to be(Currency.new('usd'))
        expect(Currency.new("USD")).to be(Currency.new('Usd'))
      end

      it 'returns new object for the different :key' do
        expect(Currency.new("USD")).to_not be(Currency.new("EUR"))
      end

      it 'is thread safe' do
        ids = []
        2.times.map{ Thread.new{ ids << Currency.new("USD").object_id }}.each(&:join)
        expect(ids.uniq.length).to eq(1)
      end
    end

    describe "#<=>" do
      it "compares objects by priority" do
        expect(Currency.new(:cad)).to be > Currency.new(:usd)
        expect(Currency.new(:usd)).to be < Currency.new(:eur)
      end

      it "compares by id when priority is the same" do
        Currency.register(iso_code: "ABD", priority: 15)
        Currency.register(iso_code: "ABC", priority: 15)
        Currency.register(iso_code: "ABE", priority: 15)
        abd = Currency.find("ABD")
        abc = Currency.find("ABC")
        abe = Currency.find("ABE")
        expect(abd).to be > abc
        expect(abe).to be > abd
        Currency.unregister("ABD")
        Currency.unregister("ABC")
        Currency.unregister("ABE")
      end

      context "when one of the currencies has no 'priority' set" do
        it "compares by id" do
          Currency.register(iso_code: "ABD") # No priority
          abd = Currency.find(:abd)
          usd = Currency.find(:usd)
          expect(abd).to be < usd
          Currency.unregister(iso_code: "ABD")
        end
      end
    end

    describe "#==" do
      it "returns true if self === other" do
        currency = Currency.new(:eur)
        expect(currency).to eq currency
      end

      it "returns true if the id is equal ignorning case" do
        expect(Currency.new(:eur)).to     eq Currency.new(:eur)
        expect(Currency.new(:eur)).to     eq Currency.new(:EUR)
        expect(Currency.new(:eur)).not_to eq Currency.new(:usd)
      end

      it "allows direct comparison of currencies and symbols/strings" do
        expect(Currency.new(:eur)).to     eq 'eur'
        expect(Currency.new(:eur)).to     eq 'EUR'
        expect(Currency.new(:eur)).to     eq :eur
        expect(Currency.new(:eur)).to     eq :EUR
        expect(Currency.new(:eur)).not_to eq 'usd'
      end

      it "allows comparison with nil and returns false" do
        expect(Currency.new(:eur)).not_to be_nil
      end
    end

    describe "#eql?" do
      it "returns true if #== returns true" do
        expect(Currency.new(:eur).eql?(Currency.new(:eur))).to be true
        expect(Currency.new(:eur).eql?(Currency.new(:usd))).to be false
      end
    end

    describe "#hash" do
      it "returns the same value for equal objects" do
        expect(Currency.new(:eur).hash).to eq Currency.new(:eur).hash
        expect(Currency.new(:eur).hash).not_to eq Currency.new(:usd).hash
      end

      it "can be used to return the intersection of Currency object arrays" do
        intersection = [Currency.new(:eur), Currency.new(:usd)] & [Currency.new(:eur)]
        expect(intersection).to eq [Currency.new(:eur)]
      end
    end

    describe "#inspect" do
      it "works as documented" do
        expect(Currency.new(:usd).inspect).to eq %Q{#<Money::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, exponent: 2.0, iso_code: USD, iso_numeric: 840, subunit: Cent, smallest_denomination: 1>}
      end
    end

    describe "#to_s" do
      it "works as documented" do
        expect(Currency.new(:usd).to_s).to eq("USD")
        expect(Currency.new(:eur).to_s).to eq("EUR")
      end
    end

    describe "#to_str" do
      it "works as documented" do
        expect(Currency.new(:usd).to_str).to eq("USD")
        expect(Currency.new(:eur).to_str).to eq("EUR")
      end
    end

    describe "#to_sym" do
      it "works as documented" do
        expect(Currency.new(:usd).to_sym).to eq(:USD)
        expect(Currency.new(:eur).to_sym).to eq(:EUR)
      end
    end

    describe "#to_currency" do
      it "works as documented" do
        usd = Currency.new(:usd)
        expect(usd.to_currency).to eq usd
      end

      it "doesn't create new symbols indefinitely" do
        expect { Currency.new("bogus") }.to raise_exception(Currency::UnknownCurrency)
        expect(Symbol.all_symbols.map{|s| s.to_s}).not_to include("bogus")
      end
    end

    describe "#code" do
      it "works as documented" do
        expect(Currency.new(:usd).code).to eq "$"
        expect(Currency.new(:azn).code).to eq "\u20BC"
      end
    end

    describe "#exponent" do
      it "conforms to iso 4217" do
        expect(Currency.new(:jpy).exponent).to eq 0
        expect(Currency.new(:usd).exponent).to eq 2
        expect(Currency.new(:iqd).exponent).to eq 3
      end
    end

    describe "#decimal_places" do
      it "proper places for known currency" do
        expect(Currency.new(:mro).decimal_places).to eq 1
        expect(Currency.new(:usd).decimal_places).to eq 2
      end

      it "proper places for custom currency" do
        register_foo
        expect(Currency.new(:foo).decimal_places).to eq 3
        unregister_foo
      end
    end
  end
end
