# RubyMoney - Money

[![Gem Version](https://badge.fury.io/rb/money.png)](http://badge.fury.io/rb/money) [![Build Status](https://travis-ci.org/RubyMoney/money.png?branch=master)](https://travis-ci.org/RubyMoney/money) [![Code Climate](https://codeclimate.com/github/RubyMoney/money.png)](https://codeclimate.com/github/RubyMoney/money)

## Contributing

See the [Contribution Guidelines](https://github.com/RubyMoney/money/blob/master/CONTRIBUTING.md)

## Introduction

This library aids one in handling money and different currencies.

### Features

- Provides a `Money` class which encapsulates all information about an certain
  amount of money, such as its value and its currency.
- Provides a `Money::Currency` class which encapsulates all information about
  a monetary unit.
- Represents monetary values as integers, in cents. This avoids floating point
  rounding errors.
- Represents currency as `Money::Currency` instances providing an high level of
  flexibility.
- Provides APIs for exchanging money from one currency to another.
- Has the ability to parse a money and currency strings
  into the corresponding Money/Currency object.

### Resources

- [Website](http://rubymoney.github.com/money)
- [API Documentation](http://rubydoc.info/gems/money/frames)
- [Git Repository](http://github.com/RubyMoney/money)

### Notes

- Your app must use UTF-8 to function with this library. There are a
  number of non-ASCII currency attributes.
- This app requires Ruby 1.9 and JSON. If you're using JRuby < 1.7.0
  you'll need to add `gem "json"` to your Gemfile or similar.

## Downloading

Install stable releases with the following command:

    gem install money

The development version (hosted on Github) can be installed with:

    git clone git://github.com/RubyMoney/money.git
    cd money
    rake install

## Usage

``` ruby
require 'money'

# 10.00 USD
money = Money.new(1000, "USD")
money.cents     #=> 1000
money.currency  #=> Currency.new("USD")

# Comparisons
Money.new(1000, "USD") == Money.new(1000, "USD")   #=> true
Money.new(1000, "USD") == Money.new(100, "USD")    #=> false
Money.new(1000, "USD") == Money.new(1000, "EUR")   #=> false
Money.new(1000, "USD") != Money.new(1000, "EUR")   #=> true

# Arithmetic
Money.new(1000, "USD") + Money.new(500, "USD") == Money.new(1500, "USD")
Money.new(1000, "USD") - Money.new(200, "USD") == Money.new(800, "USD")
Money.new(1000, "USD") / 5                     == Money.new(200, "USD")
Money.new(1000, "USD") * 5                     == Money.new(5000, "USD")

# Assumptive Currencies
Money.assume_from_symbol = true
Money.parse("$100") == Money.new(10000, "USD")
Money.parse("€100") == Money.new(10000, "EUR")
Money.parse("£100") == Money.new(10000, "GBP")

# Currency conversions
some_code_to_setup_exchange_rates
Money.new(1000, "USD").exchange_to("EUR") == Money.new(some_value, "EUR")
```

## Currency

Currencies are consistently represented as instances of `Money::Currency`.
The most part of `Money` APIs allows you to supply either a `String` or a
`Money::Currency`.

``` ruby
Money.new(1000, "USD") == Money.new(1000, Currency.new("USD"))
Money.new(1000, "EUR").currency == Currency.new("EUR")
```

A `Money::Currency` instance holds all the information about the currency,
including the currency symbol, name and much more.

``` ruby
currency = Money.new(1000, "USD").currency
currency.iso_code #=> "USD"
currency.name     #=> "United States Dollar"
```

To define a new `Money::Currency` use `Money::Currency.register` as shown
below.

``` ruby
curr = {
  :priority        => 1,
  :iso_code        => "USD",
  :iso_numeric     => "840",
  :name            => "United States Dollar",
  :symbol          => "$",
  :subunit         => "Cent"
  :subunit_to_unit => 100,
  :separator       => ".",
  :delimiter       => ","
}

Money::Currency.register(curr)
```

The pre-defined set of attributes includes:

- `:priority` a numerical value you can use to sort/group the currency list
- `:iso_code` the international 3-letter code as defined by the ISO 4217 standard
- `:iso_numeric` the international 3-digit code as defined by the ISO 4217 standard
- `:name` the currency name
- `:symbol` the currency symbol (UTF-8 encoded)
- `:subunit` the name of the fractional monetary unit
- `:subunit_to_unit` the proportion between the unit and the subunit
- `:separator` character between the whole and fraction amounts
- `:delimiter` character between each thousands place

All attributes are optional. Some attributes, such as `:symbol`, are used by
the Money class to print out a representation of the object. Other attributes,
such as `:name` or `:priority`, exist to provide a basic API you can take
advantage of to build your application.

### :priority

The priority attribute is an arbitrary numerical value you can assign to the
`Money::Currency` and use in sorting/grouping operation.

For instance, let's assume your Rails application needs to render a currency
selector like the one available
[here](http://finance.yahoo.com/currency-converter/). You can create a couple of
custom methods to return the list of major currencies and all currencies as
follows:

``` ruby
# Returns an array of currency id where
# priority < 10
def major_currencies(hash)
  hash.inject([]) do |array, (id, attributes)|
    priority = attributes[:priority]
    if priority && priority < 10
      array[priority] ||= []
      array[priority] << id
    end
    array
  end.compact.flatten
end

# Returns an array of all currency id
def all_currencies(hash)
  hash.keys
end

major_currencies(Money::Currency.table)
# => [ :usd, :eur, :bgp, :cad ]

all_currencies(Money::Currency.table)
# => [ :aed, :afn, all, ... ]
```

### Default Currency

By default `Money` defaults to USD as its currency. This can be overwritten
using:

``` ruby
Money.default_currency = Money::Currency.new("CAD")
```

If you use Rails, then `environment.rb` is a very good place to put this.

### Currency Exponent

The exponent of a money value is the number of digits after the decimal
separator (which separates the major unit from the minor unit). See e.g.
[Wikipedia on ISO 4217](http://en.wikipedia.org/wiki/ISO_4217) for more
information.  You can find the exponent (as a `Float`) by

``` ruby
Money::Currency.new("USD").exponent  # => 2.0
Money::Currency.new("JPY").exponent  # => 0.0
Money::Currency.new("MGA").exponent  # => 0.6989700043360189
```

### Currency Lookup

To find a given currency by ISO 4217 numeric code (three digits) you can do

``` ruby
Money::Currency.find_by_iso_numeric(978) #=> Money::Currency.new(:eur)
```

## Currency Exchange

Exchanging money is performed through an exchange bank object. The default
exchange bank object requires one to manually specify the exchange rate. Here's
an example of how it works:

``` ruby
Money.add_rate("USD", "CAD", 1.24515)
Money.add_rate("CAD", "USD", 0.803115)

Money.us_dollar(100).exchange_to("CAD")  # => Money.new(124, "CAD")
Money.ca_dollar(100).exchange_to("USD")  # => Money.new(80, "USD")
```

Comparison and arithmetic operations work as expected:

``` ruby
Money.new(1000, "USD") <=> Money.new(900, "USD")   # => 1; 9.00 USD is smaller
Money.new(1000, "EUR") + Money.new(10, "EUR") == Money.new(1010, "EUR")

Money.add_rate("USD", "EUR", 0.5)
Money.new(1000, "EUR") + Money.new(1000, "USD") == Money.new(1500, "EUR")
```

There is nothing stopping you from creating bank objects which scrapes
[XE](http://www.xe.com) for the current rates or just returns `rand(2)`:

``` ruby
Money.default_bank = ExchangeBankWhichScrapesXeDotCom.new
```

### Implementations

The following is a list of Money.gem compatible currency exchange rate
implementations.

- [eu_central_bank](http://github.com/RubyMoney/eu_central_bank)
- [google_currency](http://github.com/RubyMoney/google_currency)
- [nordea](https://github.com/k33l0r/nordea)
- [nbrb_currency](https://github.com/slbug/nbrb_currency)
- [money-open-exchange-rates](https://github.com/spk/money-open-exchange-rates)
- [money-historical-bank](https://github.com/atwam/money-historical-bank)

## Ruby on Rails

To integrate money in a Rails application use [money-rails](http://github.com/RubyMoney/money-rails).

For depreceated methods of integrating with Rails, check [the wiki](https://github.com/RubyMoney/money/wiki).
