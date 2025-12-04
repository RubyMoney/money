# Upgrading to Money 7.0

This guide provides step-by-step instructions for upgrading from Money 6.x to 7.0.

## Requirements

### Ruby Version
**Action Required:** Upgrade to Ruby 3.1 or later.

Money 7.0 requires Ruby >= 3.1.

```ruby
# .ruby-version
3.1.0
```

### i18n Version
**Action Required:** Ensure you're using i18n ~> 1.9.

```ruby
# Gemfile
gem 'i18n', '~> 1.9'
```

## Breaking Changes

### 1. Default Currency Changed from USD to nil

**What changed:** `Money.default_currency` now defaults to `nil` instead of `"USD"`.

**Impact:** Initializing a Money object without specifying a currency will now raise `Currency::NoCurrency` instead of defaulting to USD.

```ruby
# Before (6.x)
Money.new(100)  # => #<Money @fractional=100 @currency="USD">

# After (7.0)
Money.new(100)  # => raises Currency::NoCurrency
```

**Migration:**

Option 1: Set the default currency in your initializer (recommended if you primarily use one currency):

```ruby
# config/initializers/money.rb
Money.setup_defaults
Money.default_currency = Money::Currency.new("USD")
```

Option 2: Always specify the currency explicitly:

```ruby
Money.new(1_00, "USD")
```

### 2. Default Rounding Mode Changed

**What changed:** The default rounding mode changed from `BigDecimal::ROUND_HALF_EVEN` (banker's rounding) to `BigDecimal::ROUND_HALF_UP` (standard rounding).

**Impact:** Mathematical operations may produce different results when rounding is involved.

```ruby
# Before (6.x) - ROUND_HALF_EVEN
Money.new(2_50, "USD") / 3  # => #<Money @fractional=83.33...>

# After (7.0) - ROUND_HALF_UP
Money.new(2_50, "USD") / 3  # => #<Money @fractional=83.33...> (may differ in edge cases)
```

**Migration:**

If you need the old behavior, set it explicitly:

```ruby
# config/initializers/money.rb
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
```

### 3. Locale Backend Changes

**What changed:**
- Removed `Money.use_i18n` and `Money.use_i18n=` methods
- Removed legacy locale backend
- Default locale backend changed from `:legacy` to `:currency`

**Impact:** Formatting behavior changes if you were using the default settings.

**Migration:**

If you want i18n-based formatting (the old default behavior):

```ruby
# config/initializers/money.rb
Money.locale_backend = :i18n
```

If you want currency-based formatting (new default):

```ruby
# config/initializers/money.rb
Money.locale_backend = :currency  # This is now the default
```

If you were using `use_i18n`:

```ruby
# Before (6.x)
Money.use_i18n = true

# After (7.0)
Money.locale_backend = :i18n
```

### 4. Removed Deprecated Methods

**What changed:** Several deprecated methods have been removed.

**Migration:**

| Removed Method | Replacement |
|----------------|-------------|
| `Money.infinite_precision` | `Money.default_infinite_precision` |
| `Money.infinite_precision=` | `Money.default_infinite_precision=` |
| `Money#currency_as_string` | `Money#currency.to_s` |
| `Money#currency_as_string=` | Pass currency to constructor |
| `Money#dollars` | `Money#amount` |
| `Money.from_dollars` | `Money.from_amount` |
| `Money#round_to_nearest_cash_value` | `Money#to_nearest_cash_value.fractional` |

**Examples:**

```ruby
# Before (6.x)
Money.infinite_precision = true
money = Money.new(1_00)
money.dollars # => 1.0
Money.from_dollars(5.50, "USD")
money.round_to_nearest_cash_value

# After (7.0)
Money.default_infinite_precision = true
money = Money.new(1_00, "USD")
money.amount # => 1.0
Money.from_amount(5.50, "USD")
money.to_nearest_cash_value.fractional
```

### 5. Removed Deprecated Formatting Rules

**What changed:** Several deprecated formatting options have been removed.

**Removed options:**
- `:html`
- `:html_wrap_symbol`
- `:symbol_position`
- `:symbol_before_without_space`
- `:symbol_after_without_space`

**Migration:**

Use the supported formatting options instead:

```ruby
# Before (6.x)
money.format(symbol_position: :before)
money.format(html: true)

# After (7.0)
money.format(symbol: true)
money.format(html_wrap: true)
```

### 6. Strict Equality Comparison for Zero Amounts

**What changed:** Comparing zero amounts with different currencies using `#eql?` now returns `false` by default when `Money.strict_eql_compare = true`.

**Migration:**

The old behavior still works by default in 7.0, but you'll see deprecation warnings:

```ruby
# Current behavior (with deprecation warning)
Money.new(0, "USD").eql?(Money.new(0, "EUR"))  # => true (with warning)

# Opt in to new behavior
Money.strict_eql_compare = true
Money.new(0, "USD").eql?(Money.new(0, "EUR"))  # => false
```

**Recommended:** Set `Money.strict_eql_compare = true` in your initializer to opt in to the stricter behavior and silence warnings.

### 7. Division by Zero Now Raises an Error

**What changed:** Dividing a Money object by zero now raises an error instead of returning infinity, an undefined value or an ArgumentError.

**Impact:** Code that previously performed division by zero will now raise an exception.

```ruby
# Before (6.x)
Money.new(1_00, "USD") / 0  # => May have returned Infinity or undefined behavior

# After (7.0)
Money.new(1_00, "USD") / 0  # => raises ZeroDivisionError
```

**Migration:**

Ensure your code checks for zero before performing division:

```ruby
divisor = some_value
if divisor.zero?
  # Handle the zero case appropriately
  handle_zero_divisor
else
  Money.new(1_00, "USD") / divisor
end
```

## Currency-Specific Changes

### Serbian Dinar (RSD)
Formatting changed to use proper thousands and decimal separators:

```ruby
# Before: 12345,42 RSD
# After:  12.345,42 RSD
```

### USD Coin (USDC)
Decimal places changed from 2 to 6 to match cryptocurrency standard:

```ruby
Money.new(1_000_000, "USDC").format  # Now shows 6 decimal places
```

### Malagasy Ariary (MGA)
Changed to zero-decimal currency (subunit_to_unit: 5 → 1):

```ruby
Money.new(100, "MGA").format  # No decimal places shown
```

## Complete Initializer Example

Here's a complete initializer that maintains 6.x behavior:

```ruby
# config/initializers/money.rb

# Setup defaults first
Money.setup_defaults

# Maintain old default currency
Money.default_currency = Money::Currency.new("USD")

# Maintain old rounding mode
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

# Use i18n for formatting (old default behavior)
Money.locale_backend = :i18n

# Optional: Enable strict equality comparison
# Money.strict_eql_compare = true
```

## New Features in 7.0

While upgrading, consider taking advantage of these new features:

### Nested Bank and Rounding Mode Blocks

```ruby
Money.with_bank(bank1) do
  Money.with_bank(bank2) do
    # Uses bank2
  end
  # Uses bank1
end

Money.with_rounding_mode(BigDecimal::ROUND_UP) do
  Money.with_rounding_mode(BigDecimal::ROUND_DOWN) do
    # Uses ROUND_DOWN
  end
  # Uses ROUND_UP
end
```

### Enhanced Allocation

```ruby
# Specify precision per split
Money.new(100, "USD").allocate([1, 1, 1], 2)
```

### Currency Utilities

```ruby
currency = Money::Currency.new("USD")
currency.cents_based?  # => true
```

## Testing Your Upgrade

1. **Update your Gemfile:**
   ```ruby
   gem 'money', '~> 7.0'
   ```

2. **Run bundle update:**
   ```bash
   bundle update money
   ```

3. **Run your test suite:**
   ```bash
   bundle exec rake test  # or rspec, etc.
   ```

4. **Check for deprecation warnings** and address them.

5. **Review formatting output** if you use `Money#format` extensively.

6. **Test mathematical operations** if you rely on specific rounding behavior.

## Getting Help

- Check the [README](README.md) for detailed documentation
- Review the [CHANGELOG](CHANGELOG.md) for all changes
- Open an issue on [GitHub](https://github.com/RubyMoney/money/issues) if you encounter problems
