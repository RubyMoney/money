# RubyMoney - Money

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

- [Website](http://money.rubyforge.org)
- [API Documentation](http://money.rubyforge.org)
- [Git Repository](http://github.com/RubyMoney/money)

## Downloading

Install stable releases with the following command:

    gem install money

The development version (hosted on Github) can be installed with:

    git clone git://github.com/RubyMoney/money.git
    cd money
    rake install

## Usage

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

    # Currency conversions
    some_code_to_setup_exchange_rates
    Money.new(1000, "USD").exchange_to("EUR") == Money.new(some_value, "EUR")

## Currency

Currencies are consistently represented as instances of `Money::Currency`.
The most part of `Money` APIs allows you to supply either a `String` or a
`Money::Currency`.

    Money.new(1000, "USD") == Money.new(900, Currency.new("USD"))
    Money.new(1000, "EUR").currency == Currency.new("EUR")

A `Money::Currency` instance holds all the information about the currency,
including the currency symbol, name and much more.

    currency = Money.new(1000, "USD").currency
    currency.iso_code #=> "USD"
    currency.name     #=> "United States Dollar"

To define a new `Money::Currency` simply add a new item to the
`Money::Currency::TABLE` hash, where the key is the identifier for the currency
object and the value is a hash containing all the currency attributes.

     Money::Currency::TABLE[:usd] = {
      :priority        => 1,
      :iso_code        => "USD",
      :name            => "United States Dollar",
      :symbol          => "$",
      :subunit         => "Cent"
      :subunit_to_unit => 100,
      :separator       => ".",
      :delimiter       => ","
    }

The pre-defined set of attributes includes:

- `:priority` a numerical value you can use to sort/group the currency list
- `:iso_code` the international 3-letter code as defined by the ISO 4217 standard
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

    major_currencies(Money::Currency::TABLE)
    # => [ :usd, :eur, :bgp, :cad ]

    all_currencies(Money::Currency::TABLE)
    # => [ :aed, :afn, all, ... ]

### Default Currency

By default `Money` defaults to USD as its currency. This can be overwritten
using:

    Money.default_currency = Money::Currency.new("CAD")

If you use Rails, then `environment.rb` is a very good place to put this.

## Currency Exchange

Exchanging money is performed through an exchange bank object. The default
exchange bank object requires one to manually specify the exchange rate. Here's
an example of how it works:

    Money.add_rate("USD", "CAD", 1.24515)
    Money.add_rate("CAD", "USD", 0.803115)

    Money.us_dollar(100).exchange_to("CAD")  # => Money.new(124, "CAD")
    Money.ca_dollar(100).exchange_to("USD")  # => Money.new(80, "USD")

Comparison and arithmetic operations work as expected:

    Money.new(1000, "USD") <=> Money.new(900, "USD")   # => 1; 9.00 USD is smaller
    Money.new(1000, "EUR") + Money.new(10, "EUR") == Money.new(1010, "EUR")

    Money.add_rate("USD", "EUR", 0.5)
    Money.new(1000, "EUR") + Money.new(1000, "USD") == Money.new(1500, "EUR")

There is nothing stopping you from creating bank objects which scrapes
[XE](http://www.xe.com) for the current rates or just returns `rand(2)`:

    Money.default_bank = ExchangeBankWhichScrapesXeDotCom.new

### Implementations

The following is a list of Money.gem compatible currency exchange rate
implementations.

- [eu_central_bank](http://github.com/RubyMoney/eu_central_bank)
- [google_currency](http://github.com/RubyMoney/google_currency)

## Ruby on Rails

Use the `compose_of` helper to let Active Record deal with embedding the money
object in your models. The following example requires 2 columns:

    :price_cents, :integer, :default => 0, :null => false
    :currency, :string

Then in your model file:

    composed_of :price,
      :class_name => "Money",
      :mapping => [%w(price_cents cents), %w(currency currency_as_string)],
      :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
      :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }


For Money 2.2.x and previous versions, simply use the following `composed_of`
definition:

    composed_of :price,
      :class_name => "Money",
      :mapping => [%w(cents cents), %w(currency currency)],
      :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

For further details read the full discussion
[here](http://github.com/RubyMoney/money/issues/4#comment_224880).
