# Changelog

## Upcoming 7.0.0.alpha

- **Breaking change**: Require Ruby >= 3.1 and i18n ~> 1.9
- **Breaking change**: Remove deprecated methods:
  - `Money.infinite_precision`.
  - `Money.infinite_precision=`.
  - `Money#currency_as_string`.
  - `Money#currency_as_string=`.
- **Breaking change**: Default currency is now `nil` instead of `USD`. If you want to keep the previous behavior, set `Money.default_currency = Money::Currency.new("USD")` in your initializer. Initializing a Money object will raise a `Currency::NoCurrency` if no currency is set.
- **Breaking change**: The default rounding mode has changed from `BigDecimal::ROUND_HALF_EVEN` to `BigDecimal::ROUND_HALF_UP`. Set it explicitly using `Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN` to keep the previous behavior.
- **Potential breaking change**: Fix RSD (Serbian Dinar) formatting to be like `12.345,42 RSD`
- **Potential breaking change**: Fix USDC decimals places from 2 to 6
- **Potential breaking change**: Fix MGA (Malagasy Ariary) to be a zero-decimal currency (changing subunit_to_unit from 5 to 1)
- **Potential breaking change**: Remove special handling for Japanese language only
- Updated Armenian Dram sign and HTML entity
- Updated the Turkmen Manat symbol and HTML entity and added disambiguation symbol for TMM
- Expose Money::VERSION
- Fix typo in ILS currency
- Add Zimbabwe Gold (ZWG) currency
- Update thousands_separator for CHF
- Add Caribbean Guilder (XCG) as replacement for Netherlands Antillean Gulden (ANG)
- Add `Money#to_nearest_cash_value` to return a rounded Money instance to the smallest denomination
- Deprecate `Money#round_to_nearest_cash_value` in favor of calling `to_nearest_cash_value.fractional`
- Add `Money::Currency#cents_based?` to check if currency is cents-based
- Add ability to nest `Money.with_rounding_mode` blocks
- Allow `nil` to be used as a default_currency
- Add ability to nest `Money.with_bank` blocks

## 6.19.0

- Change Peruvian Sol (PEN) decimal mark and thousands separator.
- Fix deprecation warning for BigDecimal being moved out from stdlib.
- Improves Precision and Simplifies Allocation Logic
- explicit declaration of i18n locales
- Add space to CHF format
- Update deprecation message to suggest correct formatting.

## 6.18.0

- Add second dobra (STN) from São Tomé and Príncipe
- Add Sierra Leonean (new) leone (SLE) from Sierra Leone
- Correct South African Rand (ZAR) to use comma decimal mark, and space thousands separator
- Use euro symbol as html_entity for euro currency
- Update Georgian Lari symbol
- Add Ruby 3.1 and 3.2 to the CI matrix
- Add `Money.from_dollars` alias as a more explicit initializer, it's the same as `Money.from_amount`
- Mark Croatian Kuna (HRK) as obsolete by moving its definition to the backwards compatibility data source

## 6.17.0

- Allow true for `thousands_separator`

## 6.16.0

- Add `Money.from_cents` alias as a more explicit initializer, it's the same as `Money.new`

## 6.15.0

- Add :delimiter_pattern option to the Formatter

## 6.14.1

- Fix CHF format regression introduced in v6.14.0
- Fix deprecation warning in #format_decimal_part

## 6.14.0

- Fix Bahraini dinar symbol
- Raise exception when default currency is not set or passed as parameter
- Allow specifying default_bank as a lambda
- Allow passing a default format in currencies definition only valid without symbol_position
- Always allow comparison with zero Money
- Rename Money.infinite_precision to default_infinite_precision
- Add Currency.reset! method to reload all the default currency definitions
- Fix edgecase for Money#allocate when applying to array of all zero values

## 6.13.8
- Update symbol for XOF
- Update UYU currency symbol
- Allow double conversion using same bank
- Warn when using unsafe serializer for rate import
- Move Icelandic symbol after the amount

## 6.13.7
- Improve deprecation warnings for the upcoming major release

## 6.13.6
- Fix a regression introduced in 6.13.5 that broken RatesStore::Memory subclasses

## 6.13.5
- Raise warning on using Money.default_currency
- Raise warning on using default Money.rounding_mode
- Add Second Ouguiya MRU 929 to currency iso file
- Add symbol for UZS
- Use monitor for recursive mutual exclusion in RatesStore::Memory
- Allow passing store as a string to Money::Bank::VariableExchange (to support Rails 6)

## 6.13.4
- Update currency config for Zambian Kwacha (ZMW)
- Do not modify options passed to FormattingRules

## 6.13.3
- Remove specs from the packaged gem
- Use Currency::Loader directly without extending
- Add Money.with_rounding_mode as a replacement for calling Money.rounding_mode with a block
- Fix currency search for two digit ISO numbers
- Add description to TypeError raised by +/- operations

## 6.13.2
- Prevent Money initialization with non-finite amounts
- Convert the fractional value of a Money object to BigDecimal when initializing
- Offer replacements for currency position deprecations
- Fix Peruvian Sol symbol
- Lock i18n to <= 1.2.0 for older (< 2.3) rubies
- Prevent Divide By Zero in `Money#allocate`

## 6.13.1
- Add bolívar soberano (VES)
- Deprecate bolívar fuerte (VEF)
- Deprecate old `#format` rules passed as a symbol
- Clarify `use_i18n` deprecation
- Add `:currency` locale_backend for explicit per-currency localization

## 6.13.0
- Add :format option to the Formatter
- Add ruby 2.6.0 support
- Performance improvement (lazy stringify currency keys)
- Add `Money.locale_backend` for translation lookups
- Deprecate `use_i18n` flag in favour of `locale_backend = :i18n`
- Deprecate old formatting rules in favour of `:format`
- LVL and LTL are no longer used
- Add `Currency#iso?` for checking if currency is iso or not
- Relax versions-lock of `i18n` and `rspec` dependencies
- Add Bitcoin Cash
- Fix incorrect behaviour of `Currency#find_by_currency_iso` when given empty input

## 6.12.0
- Remove caching of `.empty`/`.zero`
- Preserve assigned bank when rounding
- Always round the fractional part when calling `#round`
- Wrap all amount parts when `:html_wrap` option is used
- Deprecate `#currency_as_string` and `#currency_as_string=` (in favour of `#with_currency`)
- Add `#with_currency` for swapping the currency
- Rewrite allocate/split (fixing some penny losing issues)

## 6.11.3
- Fix regression: if enabled use i18n locales in Money#to_s

## 6.11.2
- Fix regression: ignore formatting defaults for Money#to_s

## 6.11.1
- Fix issue with adding non-USD money to zero (used when calling `.sum` on an array)

## 6.11.0
- Support i18n 1.0
- Update yard dependency to 0.9.11
- Support for ruby 2.5.0
- Add inheritance for currency definitions
- Added new symbol for bitcoin denomination
- Specify custom rounding precision when using `infinite_precision`
- Allow splits with sums greater than 1
- Prevent arithmetic methods from losing reference to the bank
- Fix coerced zero numeric subtraction
- Fix south asian formatting to support whole numbers
- Refactor formatting logic

## 6.10.1
- Fix an issue with Money.empty memoization

## 6.10.0
- Added support for i18n version 0.9
- Disabled rounding when verifying allocation splits
- Added Chinese Yuan Offshore (CNH)
- Fixed html_entity for ARS
- Fixed KZT symbol
- Allowed comparing cross currency when both are zero
- Fixed memory rate store
- Corrected HUF subunit and thousands separator config

## 6.9.0
- Extracted heuristics into money-heuristics gem

## 6.8.4
- Resolving NIO ambiguity with CAD
- Display the BBD $ symbol before digits
- Symbol first for NIO and PAB currencies

## 6.8.3
- Added support for the British Penny (GBX)
- Fixed LKR currency html_entity symbol

## 6.8.2
- Removed subunits for HUF
- Fixed `#from_amount` accepting `nil` as currency_code
- Relaxed i18n version (< 0.9)
- Set symbol for UZS
- Added disambiguate_symbol for XFU
- Fixed Peruvian Sol name
- Fixed symbol_first for VND (now `false`)

## 6.8.1
- Fixed issue with calling `format` on a frozen `Money` object

## 6.8.0
- Ruby 2.4.0 support
- Fixed UZS syntax
- Fixed HUF smallest denomination
- Fixed ruby 1.9 issues
- Fixed html entity for COP
- Updated all currency decimals to ISO-4217
- Fixed money allocation for negative amounts
- Fixed symbol_first for RON
- Fixed disambiguate option when symbol is set to true
- Fixed thousands separator for CZK
- Improved formatter performance by precaching I18n calls

## 6.7.1
- Changed DKK symbol from 'kr' to 'kr.'
- Improved Money::Formatting#format docs
- Updated VEF symbol from 'Bs F' to 'Bs'
- `Currency#exponent` now returns Fixnum
- Fixed coercion issues
- Fixed edge case with explicit override of thousands separator and decimal mark
- `Money#==` will now raise error for non-zero numeric values
- Fixed divmod
- Added disambiguation symbol to USD Dollar
- Use disambiguation symbol when both disambiguate and symbol are true in `format` method

## 6.7.0
 - Changed `Money#<=>` to return `nil` if the comparison is inappropriate. (#584)
 - Remove implicit conversion of values being compared. Only accept `Money` and
   subclasses of `Money` for comparisons and raise TypeError otherwise.
 - When comparing fails due to `Money::Bank::UnknownRate` `Money#<=>` will now
   return `nil` as `Comparable#==` will not rescue exceptions in the next release.
 - Fix `Currency` specs for `#exponent` and `#decimal_places` not making assertions.
 - Fix a couple of Ruby warnings found in specs.
 - Fix `Money#-`,`Money#+` arithmetic for Ruby 2.3+ : check for zero value without using eql? with a Fixnum. (#577)
 - Use `Money#decimal_mark` when formatting with `rounded_infinite_precision` rule
   set to `true`.
 - Replaced meta-defined `thousands_separator` and `decimal_mark` methods with regular methods. (#579)

## 6.6.0
 - Fixed VariableExchange#exchange_with for big numbers.
 - Add Currency symbol translation support
 - `Currency.all` raises a more helpful error message
   (`Currency::MissingAttributeError`)if a currency has no priority
 - `Currency` implements `Enumerable`.
 - `Currency#<=>` sorts alphabetically by `id` if the `priority`s are the same,
   and no longer raises an error if one of the priorities is missing.
 - `Money::Currency.unregister` can take an ISO code argument in addition
   to a hash.
 - `Money::Currency.unregister` returns `true` if the given currency
   previously existed, and `false` if it didn't.
 - Fix symbol for SZL currency
 - Trying to create a Currency without an `iso_code` now raises a more
   helpful error message.
 - Add `Money.usd`, `.cad` and `.eur` as aliases for `.us_dollar`,
   `.ca_dollar`, and `.euro`.
 - Add helper methods for British pounds: `Money.pound_sterling` and
   `Money.gbp`.
 - Add `Money.from_amount` to create money from a value in units instead of
   fractional units.
 - Changed CHF symbol from 'Fr' to 'CHF'
 - Changed CLF exponent from 0 to 4
 - Changed CLP subunit_to_unit from 1 to 100
 - Minor fixes to prevent warnings on unused variables and the redefinition of
   `Money.default_currency`
 - `Money#==` changed to acknowledge that 0 in one currency is equal to 0 in any currency.
 - Changed KRW subunit_to_unit from 100 to 1
 - Decouple exchange rates storage from bank objects and formalize storage public API. Default is `Money::RatesStore::Memory`.
 - `Currency.new` now a singleton by its id

## 6.5.1
 - Fix format for BYR currency

## 6.5.0
 - Add method to round a given amount of money to the nearest possible value in cash (aka Swedish rounding).
 - Fixed the subunit_to_unit values of the CLP and KRW currencies
 - Add option for `disambiguate` symbols for formatting
 - Fixed the subunit_to_unit values of the VND currency
 - Fix formatting of NGN - show symbol before amount
 - Switch default and alternate symbols for RUB currency
 - Fix symbol for TRY currency
 - Add `Money.default_formatting_rules` hash, meant to define default rules for every time `Money#format` is called. They can be overwritten if provided on method call
 - Add support for the new official symbol for Russian Ruble (RUB) — «₽»

## 6.2.1
 - Ensure set is loaded

## 6.2.0
 - Fixes formatting error when both `thousands_separator` and `decimal_mark` was added to Money#format as options.
 - Add Money#to_i which returns the whole part of the value. i.e.
   Money.new(100, "USD").to_i # => 1
 - Fix output on Ukrainian Hryvnia symbol in HTML.
 - Add documentation about i18n in README.
 - Update iso code, symbol, subunit for the new Turkmenistani manat (GH-181)
 - Performance Improvements (1.99x faster on MRI, 1.85x on Rubinius, 41.4x faster on JRuby)
 - Money can now add and subtract Fixnum 0
 - Money#new uses Money.default_currency if currency arg is nil (GH-410)
 - Fixed formatting of NOK, putting the symbol after numbers
 - Fixed issue where rounded_infinite_precision formatting fails for some localized currencies (GH-422)

## 6.1.1
 - Remove lingering Monetize call

## 6.1.0
 - Remove deprecated methods.
 - Fix issue with block form of rounding_mode.

## 6.0.1
 - Deprecated methods lists caller on print out for easier updating.
 - Added support for Money::Currency#to_str and Money::Currency#to_sym
 - Added ability to temporally change the rounding methond inside a given block
 - Replaced parsing and core extensions with the monetize gem

## 6.0.0
- Fix BTC subunit
- New option :sign_positive to add a + sign to positive numbers
- Only allow to multiply a money by a number (int, float)
- Fix typo
- Wrap the currency symbol in a span if :html is specified in the rules
- Added Money::Currency.all method
- Allow combined comparison operator to handle zero values without rates
- Added Money::Currency.unregister method
- Works on Ruby 1.8.7
- Update deps
- Depreciate Money.parse
- Passing symbol: false when formatting 'JPY' currency in :ja locale
  will work as expected
- Divide now obeys the specified rounding mode
- Add Money#round method. This is helpful when working in infinite_precision mode and would like to perform rounding at specific points in your work flow.
- In infinite precision mode, deserialized Money objects no longer return Float values from the `fractional` method.
- Changed `thousands_separator` for Swedish Krona from dot to blank space.
- Allow mathematical operations with first argument being not an instance of Money (eg. 2 * money instead of money * 2).
- Money#dollars and Money#amount methods return numbers of type BigDecimal.
- Change Money.from_bigdecimal (and in that way .to_money too) to keep precision when using `Money.infinite_precision = true`
- Add :rounded_infinite_precision option to .format
- Changed the New Taiwan Dollar symbol position from after the amount to before the amount.
- Passing a Money instance to the Money constructor will obtain a new Money object with the same property values as the original
- Add deprecation warning to comparators
- Add Money.disallow_currency_conversion! option
- Allow to inherits from `Money`

## 5.1.1

- Added :sign_before_symbol option to format negative numbers as -£1 rather than £-1
- Ensure BigDecimal.new always receives a string - compatibility fix for ruby-1.9.2-p320
- Update Maldivian Currency to MVR and fix ރ. to be ރ
- Add exponent to currency
- Add find_numeric to find currencies by ISO 4217 numeric code.
- Fixed regression where thousands separator was missing on certain currencies. (GH-245)
- Added :symbol_before_without_space option to add a space between currency symbol and amount.

## 5.1.0

- Fix currency assumption when parsing $ with a non-USD default currency.
- Changed the Bulgarian lev symbol position from before the amount to after the amount.
- Changed the symbol and html entity for INR. It is now "₹" instead of "₨".
- Added Money::Currency.analyze for determining potential currencies for a given string using powereful algorithms - will detect symbols, iso codes and names even if mixed with text.
- Changed UGX symbol from 'Sh' to 'USh'.
- Changed SYP symbol from "£ or ل.س" to "£S". The previous symbols remain as alternates.
- Changed RWF symbol from 'FR' to 'FRw'.
- Changed RSD symbol from "din. or дин." to 'РСД'. The previous symbols remain as alternates.
- Added MGA symbol 'Ar'
- Added KGS symbol 'som'
- Changed KES symbol from 'Sh' to 'KSh'
- Added ETB symbol 'Br'
- Changed EGP symbol from "£ or ج.م" to "ج.م"
- Changed DJF symbol from 'Fr' to 'Fdj'
- Changed CVE symbol from '$ or Esc' to '$'. 'Esc' remains as an alternate symbol.
- Added BTN symbol 'Nu.'
- Changed BAM symbol from 'KM or КМ' to 'КМ', the alternate (cyrillic script) remains as an alternate symbol.
- Added alternate symbols for all currencies. For example, USD can be written as both '$' and 'US$', SEK can be 'Kr' or ':-', etc.
- Renamed Money#cents to Money#fractional. Money#cents can still be used as a synonym and equivalent of Money#fractional.
- Added Money.new_with_amount and Money#amount. Money.new_with_dollars and Money#dollars remain as synonyms.
- Calling Bank::Base.instance doesn't make Bank::VariableExchange.instance
  return Bank::Base.instance anymore (semaperepelitsa)
- Update Turkmenistan manat from TMM to TMT currency (GH-181). [Thanks @Exoth]
- Moved ZWD Zimbabwean dollars to currency_bc.json, also added there ZWL, ZWN, and ZWR Zimbabwean dollars (GH-184).
- Switch to multi_json gem (GH-170)
- Fix "warning: ambiguous first argument..." (GH-166)
- Update dependencies to latest and greatest (GH-172)
- TravisBot is now watching Pull Request!!! (GH-171)
- Minor code cleaning
- Remove subunit from South Korean won (KRW)
- Fixed bug where bankers rounding wasn't being used everywhere.

## 5.0.0

- Minor bugfix - incorrect use of character range resulted in
  botched results for Money::Parsing#extract_cents (GH-162)
- Money::Currency::TABLE removed. Use Money::Currency.register to add
  additional currencies (GH-143)
- Fix rounding error in Numeric.to_money (GH-145)
- Allow on-the-fly calculation of decimal places if not known already
  (GH-146,GH-147,GH-148)
- Move Euro symbol ahead of amount (GH-151)
- Changed settings for Polish currency (GH-152)
- Fall back to symbol if there is no html_entity present (GH-153)
- Optionally Allow parsing of money values prefixed by symbols in key
  currencies (GH-155)
- Fix bug where rates exported to a file from VariableExchange leave the File
  object open (GH-154)
- Added Money#positive? and Money#negative? methods (GH-157)
- Fix format function output for custom currencies (GH-156)
- Fix parsing of strings with 3 decimal digits (GH-158)
- Updated development dependencies
- Said goodbye to RubyForge

## 4.0.2

- Money.to_money now understands a currency option (GH-121)
- Added Money#-@ method to change object polarity (GH-122)
- Added Money#symbol_or_iso_code utility method (GH-128)
- Money.parse now understands trailing - as negative inputs (GH-133)
- Money::Currency.new now validates input to avoid memory leaks (GH-137)

- Forced UTF-8 encoding on currency JSON (GH-117)
- Fixed position of Philippine peso sign (GH-124)
- Fixed position of Danish currency sign (GH-127)

## 4.0.1

- Add missing config dir.

Money 4.0.0
===========

The big change this release is moving the currency information into a JSON
file. This should make it easier for users to add and test things. Thanks to
Steve Morris for working on this during his Mendicant University course.

In addition to this big change there were well over a dozen other minor
changes.

Features
--------
- a new exchange bank nordea has been added to the README. (k33l0r)
- a new exchange bank nbrb_currency has been added to the README. (slbug)
- update Rake tasks
- See our CI status in the README
- Add syntax highlighting to the README (phlipper)
- Remove minor unit from YEN (pwim)
- Format YEN (pwim)
- Update README for `_as_string` (mjankowski)
- Update Lebanon currency (kaleemullah)
- Update Polish złoty (holek)
- Move currency information into JSON storage! (stevemorris)
- Add ISO4217 Numeric codes (alovak)

Bugfixes
--------
- EEK currency is no longer used, kept for BC ([#issue/110](https://github.com/RubyMoney/money/issues/110))
- Lithuanian Litas symbol position fixed (laurynas)
- Fixed README typos (phlipper)
- Fixed README typos (pwim)
- Fix specs (alovak)

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
 - Fixed issue with #format(no_cents: true) (thanks Romain & Julien)

Money 3.5.5
===========

Features
--------
 - Enhancements to Money::Currency (thanks Matthew McEachen)
   - Replace delimiter with thousands_separator
   - Replace separator with decimal_mark
   - Added symbol_first and html_entity
 - Added allocation algorithm for fair(ish) splitting of money between parties
   without losing pennies (thanks Tobias Luetke)

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
   ([#issue/37](https://github.com/RubyMoney/money/issues/37))
 - Fixed String#to_money for :subunit_to_unit != 100.
   ([#issue/36](https://github.com/RubyMoney/money/issues/36))
 - Removed duplicate currencies.
   ([#issue/38](https://github.com/RubyMoney/money/issues/38))
 - Fixed issue related to JRuby returning 2 for Math.log10(1000).floor instead
   of correctly returning 3.

Money 3.1.5
===========

Features
--------
 - Added support for creating objects with the main monetary unit instead of
   cents.
   ([#issue/25](https://github.com/RubyMoney/money/issues/25))
 - Deprecated `Money#format` with separate params instead of Hash. Deprecation
   target set to Money 3.5.0.
   ([#issue/31](https://github.com/RubyMoney/money/issues/31))
 - Deprecated `Money#new(0, currency: "EUR")` in favor of
   `Money#new(0, "EUR")`. Deprecation target set to Money 3.5.0.
   ([#issue/31](https://github.com/RubyMoney/money/issues/31))
 - Throw ArgumentError when trying to multiply two Money objects together.
   ([#issue/29](https://github.com/RubyMoney/money/issues/29))
 - Update Money#parse to use :subunit_to_unit
   ([#issue/30](https://github.com/RubyMoney/money/issues/30))

Bugfixes
--------
 - Downgraded required_rubygems_version to >= 1.3.6.
   ([#issue/26](https://github.com/RubyMoney/money/issues/26))
 - Use BigDecimal when floating point calculations are needed.
 - Ruby 1.9.2 compatibility enhancements.

Money 3.1.0
===========

Features
--------
 - Implemented `Money::Bank::Base`.
   ([#issue/14](https://github.com/RubyMoney/money/issues/14))
 - Added `Money::Bank::Base#exchange_with`.
 - Deprecated `Money::Bank::Base#exchange`. Deprecation target set to Money
   3.2.0.
 - Implemented `Money::Bank::VariableExchange`
 - Deprecated `Money::VariableExchangeBank`. Deprecation target set to Money
   3.2.0.
 - Deprecate `Money::SYMBOLS`, `Money::SEPARATORS` and `Money::DELIMITERS`.
   Deprecation target set to Money 3.2.0.
   ([#issue/16](https://github.com/RubyMoney/money/issues/16))
 - Implemented `#has` for `Money` and `Money::Currency`.
 - Refactored test suite to conform to RSpec conventions.
 - Moved project from [FooBarWidget](https://github.com/FooBarWidget) to
   [RubyMoney](https://github.com/RubyMoney)
 - Added Simone Carletti to list of authors.
 - Moved `@rounding_method` from `Money::Bank::VariableExchange` to
   `Money::Bank::Base`.
   ([#issue/18](https://github.com/RubyMoney/money/issues/18))
 - Added `#setup` to `Money::Bank::Base`. Called from `#initialize`.
   ([#issue/19](https://github.com/RubyMoney/money/issues/19))
 - Added [google_currency](https://github.com/RubyMoney/google_currency) to list
   of Currency Exchange Implementations.
 - Added `#export_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](https://github.com/RubyMoney/money/issues/21))
 - Added `#import_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](https://github.com/RubyMoney/money/issues/21))
 - Removed dependency on Jeweler.
 - Replaced usage of hanna with yardoc.
 - Rewrote/reformatted all documentation.

Bugfixes
--------
 - Fixed incorrect URLs in documentation.
   ([#issue/17](https://github.com/RubyMoney/money/issues/17))
 - Updated `:subunit_to_unit` for HKD from 10 to 100.
   ([#issue/20](https://github.com/RubyMoney/money/issues/20))
 - Updated Ghanaian Cedi to use correct ISO Code, GHS.
   ([#issue/22](https://github.com/RubyMoney/money/issues/22))
 - Make `default` rake task call `spec`.
   ([#issue/23](https://github.com/RubyMoney/money/issues/23))

Money 3.1.0.pre3
================

Features
--------
 - Added [google_currency](https://github.com/RubyMoney/google_currency) to list
   of Currency Exchange Implementations.
 - Added `#export_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](https://github.com/RubyMoney/money/issues/21))
 - Added `#import_rates` to `Money::Bank::VariableExchange`.
   ([#issue/21](https://github.com/RubyMoney/money/issues/21))

Bugfixes
--------
 - Updated `:subunit_to_unit` for HKD from 10 to 100.
   ([#issue/20](https://github.com/RubyMoney/money/issues/20))

Money 3.1.0.pre2
================

Features
--------
 - Moved `@rounding_method` from `Money::Bank::VariableExchange` to
   `Money::Bank::Base`.
   ([#issue/18](https://github.com/RubyMoney/money/issues/18))
 - Added `#setup` to `Money::Bank::Base`. Called from `#initialize`.
   ([#issue/19](https://github.com/RubyMoney/money/issues/19))

Bugfixes
--------
 - Fixed incorrect URLs in documentation.
   ([#issue/17](https://github.com/RubyMoney/money/issues/17))

Money 3.1.0.pre1
================

Features
--------
 - Implemented `Money::Bank::Base`.
   ([#issue/14](https://github.com/RubyMoney/money/issues/14))
 - Added `Money::Bank::Base#exchange_with`.
 - Deprecated `Money::Bank::Base#exchange`. Deprecation target set to Money
   3.2.0.
 - Implemented `Money::Bank::VariableExchange`
 - Deprecated `Money::VariableExchangeBank`. Deprecation target set to Money
   3.2.0.
 - Deprecate `Money::SYMBOLS`, `Money::SEPARATORS` and `Money::DELIMITERS`.
   Deprecation target set to Money 3.2.0.
   ([#issue/16](https://github.com/RubyMoney/money/issues/16))
 - Implemented `#has` for `Money` and `Money::Currency`.
 - Refactored test suite to conform to RSpec conventions.
 - Moved project from [FooBarWidget](https://github.com/FooBarWidget) to
   [RubyMoney](https://github.com/RubyMoney)
 - Added Simone Carletti to list of authors.

Bugfixes
--------
 - Fixed rounding error in `Numeric#to_money`.
   ([#issue/15](https://github.com/RubyMoney/money/issues/15))

Money 3.0.5
===========

Features
--------
 - Added `Money#abs`.
 - Added ability to pass a block to `VariableExchangeBank#new` or `#exchange`,
   specifying a custom truncation method
 - Added optional `currency` argument to` Numeric#to_money`.
   ([#issue/11](https://github.com/RubyMoney/money/issues/11))
 - Added optional `currency` argument to `String#to_money`.
   ([#issue/11](https://github.com/RubyMoney/money/issues/11))
 - Use '¤' as the default currency symbol.
   ([#issue/10](https://github.com/RubyMoney/money/issues/10))

Bugfixes
--------
 - Updated `Currency#subunit_to_unit` documentation (it's an integer not a
   string).
 - Fixed issue when exchanging currencies with different `:subunit_to_unit`
   values.
 - `Numeric#to_money` now respects `:subunit_to_unit`.
   ([#issue/12](https://github.com/RubyMoney/money/issues/12))

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
   [here](https://github.com/RubyMoney/money/issues/4#issuecomment-224880)
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
