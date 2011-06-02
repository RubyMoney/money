# encoding: utf-8

require "spec_helper"

describe Money::Currency do

  specify "#initialize should lookup data from TABLE" do
    with_custom_definitions do
      Money::Currency::TABLE[:usd] = {:priority => 1, :iso_code => "USD", :name => "United States Dollar", :symbol => "$", :subunit => "Cent", :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","}
      Money::Currency::TABLE[:eur] = {:priority => 2, :iso_code => "EUR", :name => "Euro", :symbol => "€", :subunit => "Cent", :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","}

      currency = Money::Currency.new("USD")
      currency.id.should        == :usd
      currency.priority.should  == 1
      currency.iso_code.should  == "USD"
      currency.name.should      == "United States Dollar"
      currency.decimal_mark.should == "."
      currency.separator.should == "."
      currency.thousands_separator.should == ","
      currency.delimiter.should == ","
    end
  end

  specify "#initialize should raise UnknownMoney::Currency with unknown currency" do
    lambda { Money::Currency.new("xxx") }.should raise_error(Money::Currency::UnknownCurrency, /xxx/)
  end

  specify "#== should return true if self === other" do
    currency = Money::Currency.new(:eur)
    currency.should == currency
  end

  specify "#== should return true if the id is equal" do
    Money::Currency.new(:eur).should     == Money::Currency.new(:eur)
    Money::Currency.new(:eur).should_not == Money::Currency.new(:usd)
  end

  specify "#eql? should return true if #== returns true" do
    Money::Currency.new(:eur).eql?(Money::Currency.new(:eur)).should be true
    Money::Currency.new(:eur).eql?(Money::Currency.new(:usd)).should be false
  end

  specify "#hash should return the same value for equal objects" do
    Money::Currency.new(:eur).hash.should == Money::Currency.new(:eur).hash
    Money::Currency.new(:eur).hash.should_not == Money::Currency.new(:usd).hash
  end

  specify "#hash can be used to return the intersection of Currency object arrays" do
    intersection = [Money::Currency.new(:eur), Money::Currency.new(:usd)] & [Money::Currency.new(:eur)]
    intersection.should == [Money::Currency.new(:eur)]
  end

  specify "#<=> should compare objects by priority" do
    Money::Currency.new(:cad).should > Money::Currency.new(:usd)
    Money::Currency.new(:usd).should < Money::Currency.new(:eur)
  end

  specify "#to_s" do
    Money::Currency.new(:usd).to_s.should == "USD"
    Money::Currency.new(:eur).to_s.should == "EUR"
  end

  specify "#to_currency" do
    usd = Money::Currency.new(:usd)
    usd.to_currency.should == usd
  end

  specify "#inspect" do
    Money::Currency.new(:usd).inspect.should ==
    %Q{#<Money::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, iso_code: USD, subunit: Cent>}
  end


  specify "#self.find should return currency matching given id" do
    with_custom_definitions do
      Money::Currency::TABLE[:usd] = { :priority =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","   }
      Money::Currency::TABLE[:eur] = { :priority =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","   }

      expected = Money::Currency.new(:eur)
      Money::Currency.find(:eur).should  == expected
      Money::Currency.find(:EUR).should  == expected
      Money::Currency.find("eur").should == expected
      Money::Currency.find("EUR").should == expected
    end
  end

  specify "#self.find should return nil unless currency matching given id" do
    with_custom_definitions do
      Money::Currency::TABLE[:usd] = { :position =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","   }
      Money::Currency::TABLE[:eur] = { :position =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => 100, :decimal_mark => ".", :thousands_separator => ","   }

      expected = Money::Currency.new(:eur)
      Money::Currency.find(:eur).should  == expected
      Money::Currency.find(:EUR).should  == expected
      Money::Currency.find("eur").should == expected
      Money::Currency.find("EUR").should == expected
    end
  end

  specify "#self.wrap should return nil if object is nil" do
    Money::Currency.wrap(nil).should == nil
    Money::Currency.wrap(Money::Currency.new(:usd)).should == Money::Currency.new(:usd)
    Money::Currency.wrap(:usd).should == Money::Currency.new(:usd)
  end


  def with_custom_definitions(&block)
    begin
      old = Money::Currency::TABLE.dup
      Money::Currency::TABLE.clear
      yield
    ensure
      silence_warnings do
        Money::Currency.const_set("TABLE", old)
      end
    end
  end

  # Sets $VERBOSE to nil for the duration of the block and back to its original value afterwards.
  #
  #   silence_warnings do
  #     value = noisy_call # no warning voiced
  #   end
  #
  #   noisy_call # warning voiced
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

end
