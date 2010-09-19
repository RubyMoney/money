master
================

Features
--------
 - Added support for creating objects with the main monetary unit instead of cents.
   ([#issue/25](http://github.com/RubyMoney/money/issues/25))

Changes
-------
 - Deprecated `Money#format` with separate params instead of Hash.
   Deprecation target set to Money 3.5.0.
   ([#issue/31](http://github.com/RubyMoney/money/issues/31))
 - Deprecated `Money#new(0, :currency => "EUR")` in favor of `Money#new(0, "EUR")`.
   Deprecation target set to Money 3.5.0.
   ([#issue/31](http://github.com/RubyMoney/money/issues/31))
 - Removed deprecated `Money::SYMBOLS`, `Money::SEPARATORS` and `Money::DELIMITERS`.
 - Removed deprecated `Money::VariableExchangeBank`.

Money 3.1.0
===========

Features
--------
 - Implemented `Money::Bank::Base`.
   ([#issue/14](http://github.com/RubyMoney/money/issues/14))
 - Added `Money::Bank::Base#exchange_with`.
 - Deprecated `Money::Bank::Base#exchange`. Deprecation target set to Money
   3.2.0.
 - Implemented `Money::Bank::VariableExchange`
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
