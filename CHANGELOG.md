Money 3.7.1
===========

Bugfixes
--------
- Add encoding indicator to top of Gemspec

Money 3.7.0
===========

Features
--------
- add Money#to_d (thanks Andrew White)
- Add Money.use_i18n, this allows you to enable/disable i18n from being used,
  even if it's required in your app.

Money 3.6.2
===========

Features
--------
- i18n enhancements (thanks eloyesp [link](https://github.com/RubyMoney/money/commit/b2cab76c78ae04f40251fa20c4ab18faa968dc53))
- README updates (thanks pconnor)
- Break into modules
- Added `:no_cents_if_whole` format option
- Update HKD from Ho to Cent
- Performance improvements (thanks weppos)
- Added Symbol#to_currency
- Added Gemfile for development
- Updated HUF currency to use `symbol_first => false`
- Updated "Turkish New Lira" to "Turkish Lira"

Money 3.6.1
===========

Bugfixes
--------
 - Floating point comparison needs to Epsilon aware (thanks Tobias Luetke)
 - reimplement fix for #issue/43, enable Marshal.(load/dump)

Money 3.6.0
===========

Features
--------
 - Add a symbol position option for Money#format (thanks Romain, Gil and
   Julien)
 - Updated CNY to use "Fen" and subunit_to_unit of 100
 - Updates to work with gem-testers.org

Bugfixes
--------
 - Fixed issue with #format(:no_cents => true) (thanks Romain & Julien)

Money 3.5.5
===========

Features
--------
 - Enhancements to Money::Currency (thanks Matthew McEachen)
   - Replace delimiter with thousands_separator
   - Replace separator with decimal_mark
   - Added symbol_first and html_entity
 - Added allocation algorithm for fair(ish) splitting of money between parties
   without loosing pennies (thanks Tobias Luetke)

Bugfixes
--------
 - Always store cents as an Integer (thanks Abhay Kumar)
 - Fixed TypeError in rate exchange (thanks Christian Billen)
 - Cleanup #parse (thanks Tom Lianza)

Money 3.5.4
===========

Features
--------
 - Added Currency#decimal_places.

Bugfixes
--------
 - Fixed error with Money#to_s error with negative amounts that are only cents.

Money 3.5.3
===========

Bugfixes
--------
 - Fixed an error in #to_s when cents is negative

Money 3.5.2
===========

Bugfixes
--------
 - Fixed an error in #to_s which appended extra 0s incorrectly

Money 3.5.1
===========

Bugfixes
--------
 - Removed erroneous require.

Money 3.5.0
===========

Features
--------
 - Updated to RSpec2.
 - Use i18n to lookup separator and delimiter signs.
 - Removed all deprecated methods up to v3.5.0, including the following:
   - Using Money#format with params instead of a Hash.
   - Using a Hash with Money#new.
   - Using Bank#exchange, use Bank#exchange_with instead.

Bugfixes
--------
 - Updated Money#to_s to respect :separator and :subunit_to_unit.
 - Fixed Money#format for :subunit_to_unit != 100.
   ([#issue/37](http://github.com/RubyMoney/money/issue/37))
 - Fixed String#to_money for :subunit_to_unit != 100.
   ([#issue/36](http://github.com/RubyMoney/money/issue/36))
 - Removed duplicate currencies.
   ([#issue/38](http://github.com/RubyMoney/money/issue/38))
 - Fixed issue related to JRuby returning 2 for Math.log10(1000).floor instead
   of correctly returning 3.

Money 3.1.5
===========

Features
--------
 - Added support for creating objects with the main monetary unit instead of
   cents.
   ([#issue/25](http://github.com/RubyMoney/money/issues/25))
 - Deprecated `Money#format` with separate params instead of Hash. Deprecation
   target set to Money 3.5.0.
   ([#issue/31](http://github.com/RubyMoney/money/issues/31))
 - Deprecated `Money#new(0, :currency => "EUR")` in favor of
   `Money#new(0, "EUR")`. Deprecation target set to Money 3.5.0.
   ([#issue/31](http://github.com/RubyMoney/money/issues/31))
 - Throw ArgumentError when trying to multiply two Money objects together.
   ([#issue/29](http://github.com/RubyMoney/money/issues/29))
 - Update Money#parse to use :subunit_to_unit
   ([#issue/30](http://github.com/RubyMoney/money/issues/30))

Bugfixes
--------
 - Downgraded required_rubygems_version to >= 1.3.6.
   ([#issue/26](http://github.com/RubyMoney/money/issues/26))
 - Use BigDecimal when floating point calculations are needed.
 - Ruby 1.9.2 compatibility enhancements.


Money 3.1.0
===========

Features
--------
 - Implemented `Money::Bank::Base`.
   ([#issue/14](http://github.com/RubyMoney/money/issues/14))
 - Added `Money::Bank::Base#exchange_with`.
 - Deprecated `Money::Bank::Base#exchange`. Deprecation target set to Money
   3.2.0.
 - Implented `Money::Bank::VariableExchange`
 - Deprecated `Money::VariableExchangeBank`. Deprecation target set to Money
   3.2.0.
 - Deprecate `Money::SYMBOLS`, `Money::SEPARATORS` and `Money::DELIMITERS`.
   Deprecation target set to Money 3.2.0.
   ([#issue/16](http://github.com/RubyMoney/money/issues/16))
 - Implemented `#has` for `Money` and `Money::Currency`.
 - Refactored test suite to conform to RSpec conventions.
 - Moved project from [FooBarWidget](http://github.com/FooBarWidget) to
   [RubyMoney](http://github.com/RubyMoney)
 - Added Simone Carletti to list of authors.
 - Moved `@rounding_method` from `Money::Bank::VariableExchange` to
   `Money::Bank::Base`.
   ([#issue/18](http://github.com/RubyMoney/money/issues/18))
 - Added `#setup` to `Money::Bank::Base`. Called from `#initialize`.
   ([#issue/19](http://github.com/RubyMoney/money/issues/19))
 - Added [google_currency](http://github.com/RubyMoney/google_currency) to list
   of Currency Exchange Implementations.
 - Added `#export_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](http://github.com/RubyMoney/money/issues/21))
 - Added `#import_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](http://github.com/RubyMoney/money/issues/21))
 - Removed dependency on Jeweler.
 - Replaced usage of hanna with yardoc.
 - Rewrote/reformatted all documentation.

Bugfixes
--------
 - Fixed incorrect URLs in documentation.
   ([#issue/17](http://github.com/RubyMoney/money/issues/17))
 - Updated `:subunit_to_unit` for HKD from 10 to 100.
   ([#issue/20](http://github.com/RubyMoney/money/issues/20))
 - Updated Ghanaian Cedi to use correct ISO Code, GHS.
   ([#issue/22](http://github.com/RubyMoney/money/issues/22))
 - Make `default` rake task call `spec`.
   ([#issue/23](http://github.com/RubyMoney/money/issues/23))

Money 3.1.0.pre3
================

Features
--------
 - Added [google_currency](http://github.com/RubyMoney/google_currency) to list
   of Currency Exchange Implementations.
 - Added `#export_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](http://github.com/RubyMoney/money/issues/21))
 - Added `#import_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](http://github.com/RubyMoney/money/issues/21))

Bugfixes
--------
 - Updated `:subunit_to_unit` for HKD from 10 to 100.
   ([#issue/20](http://github.com/RubyMoney/money/issues/20))

Money 3.1.0.pre2
================

Features
--------
 - Moved `@rounding_method` from `Money::Bank::VariableExchange` to
   `Money::Bank::Base`.
   ([#issue/18](http://github.com/RubyMoney/money/issues/18))
 - Added `#setup` to `Money::Bank::Base`. Called from `#initialize`.
   ([#issue/19](http://github.com/RubyMoney/money/issues/19))

Bugfixes
--------
 - Fixed incorrect URLs in documentation.
   ([#issue/17](http://github.com/RubyMoney/money/issues/17))

Money 3.1.0.pre1
================

Features
--------
 - Implemented `Money::Bank::Base`.
   ([#issue/14](http://github.com/RubyMoney/money/issues/14))
 - Added `Money::Bank::Base#exchange_with`.
 - Deprecated `Money::Bank::Base#exchange`. Deprecation target set to Money
   3.2.0.
 - Implented `Money::Bank::VariableExchange`
 - Deprecated `Money::VariableExchangeBank`. Deprecation target set to Money
   3.2.0.
 - Deprecate `Money::SYMBOLS`, `Money::SEPARATORS` and `Money::DELIMITERS`.
   Deprecation target set to Money 3.2.0.
   ([#issue/16](http://github.com/RubyMoney/money/issues/16))
 - Implemented `#has` for `Money` and `Money::Currency`.
 - Refactored test suite to conform to RSpec conventions.
 - Moved project from [FooBarWidget](http://github.com/FooBarWidget) to
   [RubyMoney](http://github.com/RubyMoney)
 - Added Simone Carletti to list of authors.

Bugfixes
--------
 - Fixed rounding error in `Numeric#to_money`.
   ([#issue/15](http://github.com/RubyMoney/money/issues/15))

Money 3.0.5
===========

Features
--------
 - Added `Money#abs`.
 - Added ability to pass a block to `VariableExchangeBank#new` or `#exchange`,
   specifying a custom truncation method
 - Added optional `currency` argument to` Numeric#to_money`.
   ([#issue/11](http://github.com/RubyMoney/money/issues/11))
 - Added optional `currency` argument to `String#to_money`.
   ([#issue/11](http://github.com/RubyMoney/money/issues/11))
 - Use '¤' as the default currency symbol.
   ([#issue/10](http://github.com/RubyMoney/money/issues/10))

Bugfixes
--------
 - Updated `Currency#subunit_to_unit` documentation (it's an integer not a
   string).
 - Fixed issue when exchanging currencies with different `:subunit_to_unit`
   values.
 - `Numeric#to_money` now respects `:subunit_to_unit`.
   ([#issue/12](http://github.com/RubyMoney/money/issues/12))

Money 3.0.4
===========

Features
--------
 - Use `:subunit_to_unit` in `#to_s`, `#to_f` and `#format`.
 - Deprecated `Money#SEPARATORS` and `Money#DELIMITERS`.

Bugfixes
--------
 - Updated `#exchange` to avoid floating point rounding errors.
 - Added `:separator` and `:delimiter` to `Currency`
 - Updated the attributes of the Chilean Peso.

Money 3.0.3
===========

Features
--------
 - Added `#currency_as_string` and `#currency_as_string=` for easier
   integration with ActiveRecord/Rails

Money 3.0.2
===========

Features
--------
 - Added `#div`, `#divmod`, `#modulo`, `#%` and `#remainder` to `Money`.

Money 3.0.1
===========

Features
--------
 - Added `#eql?` to `Money`
 - Updated `Numeric#to_money` to work with all children of `Numeric` (i.e.
   `BigDecimal`, `Integer`, `Fixnum`, `Float`, etc)

Money 3.0.0
===========

Features
--------
 - Version Bump due to compatibility changes with ActiveRecord. See
   conversation
   [here](http://github.com/RubyMoney/money/issues#issue/4/comment/224880)
   for more information.

Money 2.3.0
===========

Features
--------
 - Currency is now represented by a `Currency` Object instead of a `String`.

Money 2.2.0
===========

Features
--------
 - Can now divide two Money objects by one another using `#/`.
 - Can now convert a Money object to a float using `#to_f`.
 - Users can now specify Separators and Delimiters when using `#format`.
 - Support for Brazilian Real `Money.new(1_00, :BRL)`
 - Migrated to Jeweler
