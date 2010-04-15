# encoding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'money/money'
require 'money/currency'
require 'money/defaults'


describe Currency do

  specify "#initialize should lookup data from TABLE" do
    with_custom_definitions do
      Currency::TABLE[:usd] = { :priority =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => "100"   }
      Currency::TABLE[:eur] = { :priority =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => "100"   }

      currency = Currency.new("USD")
      currency.id.should        == :usd
      currency.priority.should  == 1
      currency.iso_code.should  == "USD"
      currency.name.should      == "United States Dollar"
    end
  end

  specify "#initialize should raise UnknownCurrency with unknown currency" do
    lambda { Currency.new("xxx") }.should raise_error(Currency::UnknownCurrency, /xxx/)
  end

  specify "#== should return true if self === other" do
    currency = Currency.new(:eur)
    currency.should == currency
  end

  specify "#== should return true if the id is equal" do
    Currency.new(:eur).should     == Currency.new(:eur)
    Currency.new(:eur).should_not == Currency.new(:usd)
  end

  specify "#<=> should compare objects by priority" do
    Currency.new(:cad).should > Currency.new(:usd)
    Currency.new(:usd).should < Currency.new(:eur)
  end

  specify "#to_s" do
    Currency.new(:usd).to_s.should == "USD"
    Currency.new(:eur).to_s.should == "EUR"
  end

  specify "#inspect" do
    Currency.new(:usd).inspect.should ==
    %Q{#<Currency id: usd priority: 1, iso_code: USD, name: United States Dollar, symbol: $, subunit: Cent, subunit_to_unit: 100>}
  end


  specify "#self.find should return currency matching given id" do
    with_custom_definitions do
      Currency::TABLE[:usd] = { :priority =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => "100"   }
      Currency::TABLE[:eur] = { :priority =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => "100"   }
  
      expected = Currency.new(:eur)
      Currency.find(:eur).should  == expected
      Currency.find(:EUR).should  == expected
      Currency.find("eur").should == expected
      Currency.find("EUR").should == expected
    end
  end
  
  specify "#self.find should return nil unless currency matching given id" do
    with_custom_definitions do
      Currency::TABLE[:usd] = { :position =>   1, :iso_code => "USD", :name => "United States Dollar",                      :symbol => "$",             :subunit => "Cent",          :subunit_to_unit => "100"   }
      Currency::TABLE[:eur] = { :position =>   2, :iso_code => "EUR", :name => "Euro",                                      :symbol => "€",             :subunit => "Cent",          :subunit_to_unit => "100"   }
  
      expected = Currency.new(:eur)
      Currency.find(:eur).should  == expected
      Currency.find(:EUR).should  == expected
      Currency.find("eur").should == expected
      Currency.find("EUR").should == expected
    end
  end

  specify "#self.wrap should return nil if object is nil" do
    Currency.wrap(nil).should == nil
    Currency.wrap(Currency.new(:usd)).should == Currency.new(:usd)
    Currency.wrap(:usd).should == Currency.new(:usd)
  end


  def with_custom_definitions(&block)
    begin
      old = Currency::TABLE.dup
      Currency::TABLE.clear
      yield
    ensure
      silence_warnings do
        Currency.const_set("TABLE", old)
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
