# RubyMoney - Money

[![Gem Version](https://badge.fury.io/rb/money.svg)](https://rubygems.org/gems/money)
[![Build Status](https://travis-ci.org/RubyMoney/money.svg?branch=master)](https://travis-ci.org/RubyMoney/money)
[![Code Climate](https://codeclimate.com/github/RubyMoney/money.svg)](https://codeclimate.com/github/RubyMoney/money)
[![Coverage Status](https://coveralls.io/repos/RubyMoney/money/badge.svg?branch=master)](https://coveralls.io/r/RubyMoney/money?branch=master)
[![Inline docs](https://inch-ci.org/github/RubyMoney/money.svg)](https://inch-ci.org/github/RubyMoney/money)
[![License](https://img.shields.io/github/license/RubyMoney/money.svg)](https://opensource.org/licenses/MIT)

:warning: Please read the [migration notes](#migration-notes) before upgrading to a new major version.

If you miss String parsing, check out the new [monetize gem](https://github.com/RubyMoney/monetize).

## Contributing

See the [Contribution Guidelines](https://github.com/RubyMoney/money/blob/master/CONTRIBUTING.md)

## Introduction

A Ruby Library for dealing with money and currency conversion.

### Features

- Provides a `Money` class which encapsulates all information about a certain
  amount of money, such as its value and its currency.
- Provides a `Money::Currency` class which encapsulates all information about
  a monetary unit.
- Represents monetary values as integers, in cents. This avoids floating point
  rounding errors.
- Represents currency as `Money::Currency` instances providing a high level of
  flexibility.
- Provides APIs for exchanging money from one currency to another.

### Resources

- [Website](https://rubymoney.github.io/money/)
- [API Documentation](http://www.rubydoc.info/gems/money/frames)
- [Git Repository](https://github.com/RubyMoney/money)

### Notes

- Your app must use UTF-8 to function with this library. There are a
  number of non-ASCII currency attributes.
- This app requires JSON. If you're using JRuby < 1.7.0
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

# Unit to subunit conversions
Money.from_amount(5, "USD") == Money.new(500, "USD")  # 5 USD
Money.from_amount(5, "JPY") == Money.new(5, "JPY")    # 5 JPY
Money.from_amount(5, "TND") == Money.new(5000, "TND") # 5 TND

# Currency conversions
some_code_to_setup_exchange_rates
Money.new(1000, "USD").exchange_to("EUR") == Money.new(some_value, "EUR")

# Swap currency
Money.new(1000, "USD").with_currency("EUR") == Money.new(1000, "EUR")

# Formatting (see Formatting section for more options)
Money.new(100, "USD").format #=> "$1.00"
Money.new(100, "GBP").format #=> "£1.00"
Money.new(100, "EUR").format #=> "€1.00"
```

## Currency

Currencies are consistently represented as instances of `Money::Currency`.
The most part of `Money` APIs allows you to supply either a `String` or a
`Money::Currency`.

``` ruby
Money.new(1000, "USD") == Money.new(1000, Money::Currency.new("USD"))
Money.new(1000, "EUR").currency == Money::Currency.new("EUR")
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
  priority:            1,
  iso_code:            "USD",
  iso_numeric:         "840",
  name:                "United States Dollar",
  symbol:              "$",
  subunit:             "Cent",
  subunit_to_unit:     100,
  decimal_mark:        ".",
  thousands_separator: ","
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
- `:decimal_mark` character between the whole and fraction amounts
- `:thousands_separator` character between each thousands place

All attributes except `:iso_code` are optional. Some attributes, such as
`:symbol`, are used by the Money class to print out a representation of the
object. Other attributes, such as `:name` or `:priority`, exist to provide a
basic API you can take advantage of to build your application.

### :priority

The priority attribute is an arbitrary numerical value you can assign to the
`Money::Currency` and use in sorting/grouping operation.

For instance, let's assume your Rails application needs to render a currency
selector like the one available
[here](https://finance.yahoo.com/currency-converter/). You can create a couple of
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
# => [:usd, :eur, :gbp, :aud, :cad, :jpy]

all_currencies(Money::Currency.table)
# => [:aed, :afn, :all, ...]
```

### Default Currency

By default `Money` defaults to USD as its currency. This can be overwritten
using:

``` ruby
Money.default_currency = Money::Currency.new("CAD")
```

If you use [Rails](https://github.com/RubyMoney/money/tree/master#ruby-on-rails), then `config/initializers/money.rb` is a very good place to put this.

### Currency Exponent

The exponent of a money value is the number of digits after the decimal
separator (which separates the major unit from the minor unit). See e.g.
[ISO 4217](https://www.currency-iso.org/en/shared/amendments/iso-4217-amendment.html) for more
information. You can find the exponent (as an `Integer`) by

``` ruby
Money::Currency.new("USD").exponent  # => 2
Money::Currency.new("JPY").exponent  # => 0
Money::Currency.new("MGA").exponent  # => 1
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

### Exchange rate stores

The default bank is initialized with an in-memory store for exchange rates.

```ruby
Money.default_bank = Money::Bank::VariableExchange.new(Money::RatesStore::Memory.new)
```

You can pass your own store implementation, i.e. for storing and retrieving rates off a database, file, cache, etc.

```ruby
Money.default_bank = Money::Bank::VariableExchange.new(MyCustomStore.new)
```

Stores must implement the following interface:

```ruby
# Add new exchange rate.
# @param [String] iso_from Currency ISO code. ex. 'USD'
# @param [String] iso_to Currency ISO code. ex. 'CAD'
# @param [Numeric] rate Exchange rate. ex. 0.0016
#
# @return [Numeric] rate.
def add_rate(iso_from, iso_to, rate); end

# Get rate. Must be idempotent. i.e. adding the same rate must not produce duplicates.
# @param [String] iso_from Currency ISO code. ex. 'USD'
# @param [String] iso_to Currency ISO code. ex. 'CAD'
#
# @return [Numeric] rate.
def get_rate(iso_from, iso_to); end

# Iterate over rate tuples (iso_from, iso_to, rate)
#
# @yieldparam iso_from [String] Currency ISO string.
# @yieldparam iso_to [String] Currency ISO string.
# @yieldparam rate [Numeric] Exchange rate.
#
# @return [Enumerator]
#
# @example
#   store.each_rate do |iso_from, iso_to, rate|
#     puts [iso_from, iso_to, rate].join
#   end
def each_rate(&block); end

# Wrap store operations in a thread-safe transaction
# (or IO or Database transaction, depending on your implementation)
#
# @yield [n] Block that will be wrapped in transaction.
#
# @example
#   store.transaction do
#     store.add_rate('USD', 'CAD', 0.9)
#     store.add_rate('USD', 'CLP', 0.0016)
#   end
def transaction(&block); end

# Serialize store and its content to make Marshal.dump work.
#
# Returns an array with store class and any arguments needed to initialize the store in the current state.

# @return [Array] [class, arg1, arg2]
def marshal_dump; end
```

The following example implements an `ActiveRecord` store to save exchange rates to a database.

```ruby
# rails g model exchange_rate from:string to:string rate:float

# for Rails 5 replace ActiveRecord::Base with ApplicationRecord
class ExchangeRate < ActiveRecord::Base
  def self.get_rate(from_iso_code, to_iso_code)
    rate = find_by(from: from_iso_code, to: to_iso_code)
    rate.present? ? rate.rate : nil
  end

  def self.add_rate(from_iso_code, to_iso_code, rate)
    exrate = find_or_initialize_by(from: from_iso_code, to: to_iso_code)
    exrate.rate = rate
    exrate.save!
  end
end
```

Now you can use it with the default bank.

```ruby
# For Rails 6 pass model name as a string to make it compatible with zeitwerk
# Money.default_bank = Money::Bank::VariableExchange.new("ExchangeRate")
Money.default_bank = Money::Bank::VariableExchange.new(ExchangeRate)

# Add to the underlying store
Money.default_bank.add_rate('USD', 'CAD', 0.9)
# Retrieve from the underlying store
Money.default_bank.get_rate('USD', 'CAD') # => 0.9
# Exchanging amounts just works.
Money.new(1000, 'USD').exchange_to('CAD') #=> #<Money fractional:900 currency:CAD>
```

There is nothing stopping you from creating store objects which scrapes
[XE](http://www.xe.com) for the current rates or just returns `rand(2)`:

``` ruby
Money.default_bank = Money::Bank::VariableExchange.new(StoreWhichScrapesXeDotCom.new)
```

You can also implement your own Bank to calculate exchanges differently.
Different banks can share Stores.

```ruby
Money.default_bank = MyCustomBank.new(Money::RatesStore::Memory.new)
```

If you wish to disable automatic currency conversion to prevent arithmetic when
currencies don't match:

``` ruby
Money.disallow_currency_conversion!
```

### Implementations

The following is a list of Money.gem compatible currency exchange rate
implementations.

- [eu_central_bank](https://github.com/RubyMoney/eu_central_bank)
- [google_currency](https://github.com/RubyMoney/google_currency)
- [currencylayer](https://github.com/askuratovsky/currencylayer)
- [nordea](https://github.com/matiaskorhonen/nordea)
- [nbrb_currency](https://github.com/slbug/nbrb_currency)
- [money-currencylayer-bank](https://github.com/phlegx/money-currencylayer-bank)
- [money-open-exchange-rates](https://github.com/spk/money-open-exchange-rates)
- [money-historical-bank](https://github.com/atwam/money-historical-bank)
- [russian_central_bank](https://github.com/rmustafin/russian_central_bank)
- [money-uphold-bank](https://github.com/subvisual/money-uphold-bank)

## Formatting

There are several formatting rules for when `Money#format` is called. For more information, check out the [formatting module source](https://github.com/RubyMoney/money/blob/master/lib/money/money/formatter.rb), or read the latest release's [rdoc version](http://www.rubydoc.info/gems/money/Money/Formatter).

If you wish to format money according to the EU's [Rules for expressing monetary units](http://publications.europa.eu/code/en/en-370303.htm#position) in either English, Irish, Latvian or Maltese:

```ruby
m = Money.new('123', :gbp) # => #<Money fractional:123 currency:GBP>
m.format(symbol: m.currency.to_s + ' ') # => "GBP 1.23"
```

## Rounding

By default, `Money` objects are rounded to the nearest cent and the additional precision is not preserved:

```ruby
Money.from_amount(2.34567).format #=> "$2.35"
```

To retain the additional precision, you will also need to set `infinite_precision` to `true`.

```ruby
Money.infinite_precision = true
Money.from_amount(2.34567).format #=> "$2.34567"
```

To round to the nearest cent (or anything more precise), you can use the `round` method. However, note that the `round` method on a `Money` object does not work the same way as a normal Ruby `Float` object. Money's `round` method accepts different arguments. The first argument to the round method is the rounding mode, while the second argument is the level of precision relative to the cent.

```
# Float
2.34567.round     #=> 2
2.34567.round(2)  #=> 2.35

# Money
Money.infinite_precision = true
Money.new(2.34567).format       #=> "$0.0234567"
Money.new(2.34567).round.format #=> "$0.02"
Money.new(2.34567).round(BigDecimal::ROUND_HALF_UP, 2).format #=> "$0.0235"
```

You can set the default rounding mode by passing one of the `BigDecimal` mode enumerables like so:
```ruby
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
```
See [BigDecimal::ROUND_MODE](https://ruby-doc.org/stdlib-2.5.1/libdoc/bigdecimal/rdoc/BigDecimal.html#ROUND_MODE) for more information


## Ruby on Rails

To integrate money in a Rails application use [money-rails](https://github.com/RubyMoney/money-rails).

For deprecated methods of integrating with Rails, check [the wiki](https://github.com/RubyMoney/money/wiki).

## Localization

In order to localize formatting you can use `I18n` gem:

```ruby
Money.locale_backend = :i18n
```

With this enabled a thousands seperator and a decimal mark will get looked up in your `I18n` translation files. In a Rails application this may look like:

```yml
# config/locale/en.yml
en:
  number:
    currency:
      format:
        delimiter: ","
        separator: "."
  # falling back to
  number:
    format:
      delimiter: ","
      separator: "."
```

For this example `Money.new(123456789, "SEK").format` will return `1,234,567.89
kr` which otherwise would have returned `1 234 567,89 kr`.

This will work seamlessly with [rails-i18n](https://github.com/svenfuchs/rails-i18n) gem that already has a lot of locales defined.

If you wish to disable this feature and use defaults instead:

``` ruby
Money.locale_backend = nil
```

### Deprecation

The current default behaviour always checks the I18n locale first, falling back to "per currency"
localization. This is now deprecated and will be removed in favour of explicitly defined behaviour
in the next major release.

If you would like to use I18n localization (formatting depends on the locale):

```ruby
Money.locale_backend = :i18n

# example (using default localization from rails-i18n):
I18n.locale = :en
Money.new(10_000_00, 'USD').format # => $10,000.00
Money.new(10_000_00, 'EUR').format # => €10,000.00

I18n.locale = :es
Money.new(10_000_00, 'USD').format # => $10.000,00
Money.new(10_000_00, 'EUR').format # => €10.000,00
```

If you need to localize the position of the currency symbol, you
have to pass it manually. *Note: this will become the default formatting
behavior in the next version.*

```ruby
I18n.locale = :fr
format = I18n.t :format, scope: 'number.currency.format'
Money.new(10_00, 'EUR').format(format: format) # => 10,00 €
```

For the legacy behaviour of "per currency" localization (formatting depends only on currency):

```ruby
Money.locale_backend = :currency

# example:
Money.new(10_000_00, 'USD').format # => $10,000.00
Money.new(10_000_00, 'EUR').format # => €10.000,00
```

In case you don't need localization and would like to use default values (can be redefined using
`Money.default_formatting_rules`):

```ruby
Money.locale_backend = nil

# example:
Money.new(10_000_00, 'USD').format # => $10000.00
Money.new(10_000_00, 'EUR').format # => €10000.00
```

## Collection

In case you're working with collections of `Money` instances, have a look at [money-collection](https://github.com/RubyMoney/money-collection)
for improved performance and accuracy.

### Troubleshooting

If you don't have some locale and don't want to get a runtime error such as:

    I18n::InvalidLocale: :en is not a valid locale

Set the following:
``` ruby
I18n.enforce_available_locales = false
```

## Heuristics

Prior to v6.9.0 heuristic analysis of string input was part of this gem. Since then it was extracted in to [money-heuristics gem](https://github.com/RubyMoney/money-heuristics).

## Migration Notes

#### Version 6.0.0

- The `Money#dollars` and `Money#amount` methods now return instances of
  `BigDecimal` rather than `Float`. We should avoid representing monetary
  values with floating point types so to avoid a whole class of errors relating
  to lack of precision. There are two migration options for this change:
  * The first is to test your application and where applicable update the
    application to accept a `BigDecimal` return value. This is the recommended
    path.
  * The second is to migrate from the `#amount` and `#dollars` methods to use
    the `#to_f` method instead. This option should only be used where `Float`
    is the desired type and nothing else will do for your application's
    requirements.
