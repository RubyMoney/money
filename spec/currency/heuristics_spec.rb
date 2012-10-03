# encoding: utf-8
require 'spec_helper'

describe Money::Currency::Heuristics do
  describe "#analyze_string" do
    let(:it) { Money::Currency }

    it "is not affected by blank characters and numbers" do
      it.analyze('123').should == []
      it.analyze('\n123 \t').should == []
    end

    it "returns nothing when given nothing" do
      it.analyze('').should == []
      it.analyze(nil).should == []
    end

    it "finds a currency by use of its symbol" do
      it.analyze('zł').should == ['PLN']
    end

    it "is not affected by trailing dot" do
      it.analyze('zł.').should == ['PLN']
    end

    it "finds match even if has numbers after" do
      it.analyze('zł 123').should == ['PLN']
    end

    it "finds match even if has numbers before" do
      it.analyze('123 zł').should == ['PLN']
    end

    it "find match even if symbol is next to number" do
      it.analyze('300zł').should == ['PLN']
    end

    it "finds match even if has numbers with delimiters" do
      it.analyze('zł 123,000.50').should == ['PLN']
      it.analyze('zł123,000.50').should == ['PLN']
    end

    it "finds currencies with dots in symbols" do
      it.analyze('L.E.').should == ['EGP']
    end

    it "finds by name" do
      it.analyze('1900 bulgarian lev').should == ['BGN']
      it.analyze('Swedish Krona').should == ['SEK']
    end

    it "Finds several currencies when several match" do
      r = it.analyze('$400')
      r.should include("ARS")
      r.should include("USD")
      r.should include("NZD")

      r = it.analyze('9000 £')
      r.should include("GBP")
      r.should include("SHP")
      r.should include("SYP")
    end

    it "should use alternate symbols" do
      it.analyze('US$').should == ['USD']
    end

    it "finds a currency by use of its iso code" do
      it.analyze('USD 200').should == ['USD']
    end

    it "finds currencies in the middle of a sentence!" do
      it.analyze('It would be nice to have 10000 Albanian lek by tomorrow!').should == ['ALL']
    end

    it "finds several currencies in the same text!" do
      it.analyze("10EUR is less than 100:- but really, I want US$1").should == ['EUR', 'SEK', 'USD']
    end

    it "should function with unicode characters" do
      it.analyze("10 դր.").should == ["AMD"]
    end
  end
end
