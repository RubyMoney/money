# encoding: utf-8
require "money/bank/variable_exchange"
require "money/bank/single_currency"
require "money/money/arithmetic"
require "money/money/constructors"
require "money/money/formatter"
require "money/money/allocation"
require "money/money/locale_backend"

# "Money is any object or record that is generally accepted as payment for
# goods and services and repayment of debts in a given socio-economic context
# or country." -Wikipedia
#
# An instance of Money represents an amount of a specific currency.
#
# Money is a value object and should be treated as immutable.
#
# @see http://en.wikipedia.org/wiki/Money
class Money
  include Comparable
  include Money::Arithmetic
  extend Constructors

  # Raised when smallest denomination of a currency is not defined
  class UndefinedSmallestDenomination < StandardError; end

  # Convenience method for fractional part of the amount. Synonym of #fractional
  #
  # @return [Integer] when infinite_precision is false
  # @return [BigDecimal] when infinite_precision is true
  #
  # @see infinite_precision
  def cents
    fractional
  end

  # The value of the monetary amount represented in the fractional or subunit
  # of the currency.
  #
  # For example, in the US dollar currency the fractional unit is cents, and
  # there are 100 cents in one US dollar. So given the Money representation of
  # one US dollar, the fractional interpretation is 100.
  #
  # Another example is that of the Kuwaiti dinar. In this case the fractional
  # unit is the fils and there 1000 fils to one Kuwaiti dinar. So given the
  # Money representation of one Kuwaiti dinar, the fractional interpretation is
  # 1000.
  #
  # @return [Integer] when infinite_precision is false
  # @return [BigDecimal] when infinite_precision is true
  #
  # @see infinite_precision
  def fractional
    # Ensure we have a BigDecimal. If the Money object is created
    # from YAML, @fractional can end up being set to a Float.
    fractional = as_d(@fractional)

    return_value(fractional)
  end

  # Round a given amount of money to the nearest possible amount in cash value. For
  # example, in Swiss franc (CHF), the smallest possible amount of cash value is
  # CHF 0.05. Therefore, this method rounds CHF 0.07 to CHF 0.05, and CHF 0.08 to
  # CHF 0.10.
  #
  # @return [Integer] when infinite_precision is false
  # @return [BigDecimal] when infinite_precision is true
  #
  # @see infinite_precision
  def round_to_nearest_cash_value
    unless self.currency.smallest_denomination
      raise UndefinedSmallestDenomination, 'Smallest denomination of this currency is not defined'
    end

    fractional = as_d(@fractional)
    smallest_denomination = as_d(self.currency.smallest_denomination)
    rounded_value = (fractional / smallest_denomination).round(0, self.class.rounding_mode) * smallest_denomination

    return_value(rounded_value)
  end

  # @!attribute [r] currency
  #   @return [Currency] The money's currency.
  # @!attribute [r] bank
  #   @return [Money::Bank::Base] The +Money::Bank+-based object which currency
  #     exchanges are performed with.

  attr_reader :currency, :bank

  # Class Methods
  class << self

    # @!attribute [rw] default_bank
    #   Used to set a default bank for currency exchange.
    #
    #   Each Money object is associated with a bank
    #   object, which is responsible for currency exchange. This property
    #   allows you to specify the default bank object. The default value for
    #   this property is an instance of +Bank::VariableExchange.+ It allows
    #   one to specify custom exchange rates.
    #
    #   @return [Money::Bank::Base]
    #
    # @!attribute default_formatting_rules
    #   Used to define a default hash of rules for every time
    #   +Money#format+ is called.  Rules provided on method call will be
    #   merged with the default ones.  To overwrite a rule, just provide the
    #   intended value while calling +format+.
    #
    #   @see Money::Formatter#initialize Money::Formatter for more details
    #
    #   @example
    #     Money.default_formatting_rules = { display_free: true }
    #     Money.new(0, "USD").format                          # => "free"
    #     Money.new(0, "USD").format(display_free: false)  # => "$0.00"
    #
    #   @return [Hash]
    #
    # @!attribute [rw] use_i18n
    #   Used to disable i18n even if it's used by other components of your app.
    #
    #   @return [Boolean]
    #
    # @!attribute [rw] infinite_precision
    #   Used to enable infinite precision cents
    #
    #   @return [Boolean]
    #
    # @!attribute [rw] conversion_precision
    #   Used to specify precision for converting Rational to BigDecimal
    #
    #   @return [Integer]
    attr_accessor :default_bank, :default_formatting_rules,
      :infinite_precision, :conversion_precision

    attr_reader :use_i18n, :locale_backend
  end

  # @!attribute default_currency
  #   @return [Money::Currency] The default currency, which is used when
  #     +Money.new+ is called without an explicit currency argument. The
  #     default value is Currency.new("USD"). The value must be a valid
  #     +Money::Currency+ instance.
  def self.default_currency
    if @using_deprecated_default_currency
      warn '[WARNING] The default currency will change from `USD` to `nil` in the next major release. Make ' \
           'sure to set it explicitly using `Money.default_currency=` to avoid potential issues'
      @using_deprecated_default_currency = false
    end

    if @default_currency.respond_to?(:call)
      Money::Currency.new(@default_currency.call)
    else
      Money::Currency.new(@default_currency)
    end
  end

  def self.default_currency=(currency)
    @using_deprecated_default_currency = false
    @default_currency = currency
  end

  def self.locale_backend=(value)
    @locale_backend = value ? LocaleBackend.find(value) : nil
  end

  # @attr_writer rounding_mode Use this to specify the rounding mode
  def self.rounding_mode=(new_rounding_mode)
    @using_deprecated_default_rounding_mode = false
    @rounding_mode = new_rounding_mode
  end

  def self.use_i18n=(value)
    if value
      warn '[DEPRECATION] `use_i18n` is deprecated - use `Money.locale_backend = :i18n` instead for locale based formatting'
    else
      warn '[DEPRECATION] `use_i18n` is deprecated - use `Money.locale_backend = :currency` instead for currency based formatting'
    end

    @use_i18n = value
  end

  def self.setup_defaults
    # Set the default bank for creating new +Money+ objects.
    self.default_bank = Bank::VariableExchange.instance

    # Set the default currency for creating new +Money+ object.
    self.default_currency = Currency.new("USD")
    @using_deprecated_default_currency = true

    # Default to using i18n
    @use_i18n = true

    # Default to using legacy locale backend
    self.locale_backend = :legacy

    # Default to not using infinite precision cents
    self.infinite_precision = false

    # Default to bankers rounding
    self.rounding_mode = BigDecimal::ROUND_HALF_EVEN
    @using_deprecated_default_rounding_mode = true

    # Default the conversion of Rationals precision to 16
    self.conversion_precision = 16
  end

  def self.inherited(base)
    base.setup_defaults
  end

  setup_defaults

  # Use this to return the rounding mode.
  #
  # @param [BigDecimal::ROUND_MODE] mode
  #
  # @return [BigDecimal::ROUND_MODE] rounding mode
  def self.rounding_mode(mode = nil)
    if mode
      warn "[DEPRECATION] calling `rounding_mode` with a block is deprecated. Please use `.with_rounding_mode` instead."
      return with_rounding_mode(mode) { yield }
    end

    return Thread.current[:money_rounding_mode] if Thread.current[:money_rounding_mode]

    if @using_deprecated_default_rounding_mode
      warn '[WARNING] The default rounding mode will change from `ROUND_HALF_EVEN` to `ROUND_HALF_UP` in the ' \
           'next major release. Set it explicitly using `Money.rounding_mode=` to avoid potential problems.'
      @using_deprecated_default_rounding_mode = false
    end

    @rounding_mode
  end

  # Temporarily changes the rounding mode in a given block.
  #
  # @param [BigDecimal::ROUND_MODE] mode
  #
  # @yield The block within which rounding mode will be changed. Its return
  #   value will also be the return value of the whole method.
  #
  # @return [Object] block results
  #
  # @example
  #   fee = Money.with_rounding_mode(BigDecimal::ROUND_HALF_UP) do
  #     Money.new(1200) * BigDecimal('0.029')
  #   end
  def self.with_rounding_mode(mode)
    Thread.current[:money_rounding_mode] = mode
    yield
  ensure
    Thread.current[:money_rounding_mode] = nil
  end

  # Adds a new exchange rate to the default bank and return the rate.
  #
  # @param [Currency, String, Symbol] from_currency Currency to exchange from.
  # @param [Currency, String, Symbol] to_currency Currency to exchange to.
  # @param [Numeric] rate Rate to exchange with.
  #
  # @return [Numeric]
  #
  # @example
  #   Money.add_rate("USD", "CAD", 1.25) #=> 1.25
  def self.add_rate(from_currency, to_currency, rate)
    Money.default_bank.add_rate(from_currency, to_currency, rate)
  end

  # Sets the default bank to be a SingleCurrency bank that raises on
  # currency exchange. Useful when apps operate in a single currency at a time.
  def self.disallow_currency_conversion!
    self.default_bank = Bank::SingleCurrency.instance
  end

  # Creates a new Money object of value given in the +unit+ of the given
  # +currency+.
  #
  # @param [Numeric] amount The numerical value of the money.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @example
  #   Money.from_amount(23.45, "USD") # => #<Money fractional:2345 currency:USD>
  #   Money.from_amount(23.45, "JPY") # => #<Money fractional:23 currency:JPY>
  #
  # @return [Money]
  #
  # @see #initialize
  def self.from_amount(amount, currency = default_currency, bank = default_bank)
    raise ArgumentError, "'amount' must be numeric" unless Numeric === amount

    currency = Currency.wrap(currency) || Money.default_currency
    value = amount.to_d * currency.subunit_to_unit
    value = value.round(0, rounding_mode) unless infinite_precision
    new(value, currency, bank)
  end

  # Creates a new Money object of value given in the
  # +fractional unit+ of the given +currency+.
  #
  # Alternatively you can use the convenience
  # methods like {Money.ca_dollar} and {Money.us_dollar}.
  #
  # @param [Object] obj Either the fractional value of the money,
  #   a Money object, or a currency. (If passed a currency as the first
  #   argument, a Money will be created in that currency with fractional value
  #   = 0.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100)        #=> #<Money @fractional=100 @currency="USD">
  #   Money.new(100, "USD") #=> #<Money @fractional=100 @currency="USD">
  #   Money.new(100, "EUR") #=> #<Money @fractional=100 @currency="EUR">
  #
  def initialize(obj, currency = Money.default_currency, bank = Money.default_bank)
    @fractional = as_d(obj.respond_to?(:fractional) ? obj.fractional : obj)
    @currency   = obj.respond_to?(:currency) ? obj.currency : Currency.wrap(currency)
    @currency ||= Money.default_currency
    @bank       = obj.respond_to?(:bank) ? obj.bank : bank

    # BigDecimal can be Infinity and NaN, money of that amount does not make sense
    raise ArgumentError, 'must be initialized with a finite value' unless @fractional.finite?
  end

  # Assuming using a currency using dollars:
  # Returns the value of the money in dollars,
  # instead of in the fractional unit cents.
  #
  # Synonym of #amount
  #
  # @return [BigDecimal]
  #
  # @example
  #   Money.new(1_00, "USD").dollars   # => BigDecimal("1.00")
  #
  # @see #amount
  # @see #to_d
  # @see #cents
  #
  def dollars
    amount
  end

  # Returns the numerical value of the money
  #
  # @return [BigDecimal]
  #
  # @example
  #   Money.new(1_00, "USD").amount    # => BigDecimal("1.00")
  #
  # @see #to_d
  # @see #fractional
  #
  def amount
    to_d
  end

  # Return string representation of currency object
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, :USD).currency_as_string #=> "USD"
  def currency_as_string
    warn "[DEPRECATION] `currency_as_string` is deprecated. Please use `.currency.to_s` instead."
    currency.to_s
  end

  # Set currency object using a string
  #
  # @param [String] val The currency string.
  #
  # @return [Money::Currency]
  #
  # @example
  #   Money.new(100).currency_as_string("CAD") #=> #<Money::Currency id: cad>
  def currency_as_string=(val)
    warn "[DEPRECATION] `currency_as_string=` is deprecated - Money instances are immutable." \
      " Please use `with_currency` instead."
    @currency = Currency.wrap(val)
  end

  # Returns a Integer hash value based on the +fractional+ and +currency+ attributes
  # in order to use functions like & (intersection), group_by, etc.
  #
  # @return [Integer]
  #
  # @example
  #   Money.new(100).hash #=> 908351
  def hash
    [fractional.hash, currency.hash].hash
  end

  # Uses +Currency#symbol+. If +nil+ is returned, defaults to "¤".
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, "USD").symbol #=> "$"
  def symbol
    currency.symbol || "¤"
  end

  # Common inspect function
  #
  # @return [String]
  def inspect
    "#<#{self.class.name} fractional:#{fractional} currency:#{currency}>"
  end

  # Returns the amount of money as a string.
  #
  # @return [String]
  #
  # @example
  #   Money.ca_dollar(100).to_s #=> "1.00"
  def to_s
    format thousands_separator: '',
           no_cents_if_whole: currency.decimal_places == 0,
           symbol: false,
           ignore_defaults: true
  end

  # Return the amount of money as a BigDecimal.
  #
  # @return [BigDecimal]
  #
  # @example
  #   Money.us_dollar(1_00).to_d #=> BigDecimal("1.00")
  def to_d
    as_d(fractional) / as_d(currency.subunit_to_unit)
  end

  # Return the amount of money as a Integer.
  #
  # @return [Integer]
  #
  # @example
  #   Money.us_dollar(1_00).to_i #=> 1
  def to_i
    to_d.to_i
  end

  # Return the amount of money as a float. Floating points cannot guarantee
  # precision. Therefore, this function should only be used when you no longer
  # need to represent currency or working with another system that requires
  # floats.
  #
  # @return [Float]
  #
  # @example
  #   Money.us_dollar(100).to_f #=> 1.0
  def to_f
    to_d.to_f
  end

  # Returns a new Money instance in a given currency leaving the amount intact
  # and not performing currency conversion.
  #
  # @param [Currency, String, Symbol] new_currency Currency of the new object.
  #
  # @return [self]
  def with_currency(new_currency)
    new_currency = Currency.wrap(new_currency)
    if !new_currency || currency == new_currency
      self
    else
      self.class.new(fractional, new_currency, bank)
    end
  end

  # Conversion to +self+.
  #
  # @return [self]
  def to_money(given_currency = nil)
    given_currency = Currency.wrap(given_currency)
    if given_currency.nil? || self.currency == given_currency
      self
    else
      exchange_to(given_currency)
    end
  end

  # Receive the amount of this money object in another Currency.
  #
  # @param [Currency, String, Symbol] other_currency Currency to exchange to.
  #
  # @yield [n] Optional block to use when rounding after exchanging one currency
  #  for another.
  # @yieldparam [Float] n The resulting float after exchanging one currency for
  #  another.
  # @yieldreturn [Integer]
  #
  # @return [Money]
  #
  # @example
  #   Money.new(2000, "USD").exchange_to("EUR")
  #   Money.new(2000, "USD").exchange_to("EUR") {|x| x.round}
  #   Money.new(2000, "USD").exchange_to(Currency.new("EUR"))
  def exchange_to(other_currency, &rounding_method)
    other_currency = Currency.wrap(other_currency)
    if self.currency == other_currency
      self
    else
      @bank.exchange_with(self, other_currency, &rounding_method)
    end
  end

  # Receive a money object with the same amount as the current Money object
  # in United States dollar.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.new(100, "CAD").as_us_dollar
  #   n.currency #=> #<Money::Currency id: usd>
  def as_us_dollar
    exchange_to("USD")
  end

  # Receive a money object with the same amount as the current Money object
  # in Canadian dollar.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.new(100, "USD").as_ca_dollar
  #   n.currency #=> #<Money::Currency id: cad>
  def as_ca_dollar
    exchange_to("CAD")
  end

  # Receive a money object with the same amount as the current Money object
  # in euro.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.new(100, "USD").as_euro
  #   n.currency #=> #<Money::Currency id: eur>
  def as_euro
    exchange_to("EUR")
  end

  # Splits a given amount in parts without losing pennies. The left-over pennies will be
  # distributed round-robin amongst the parties. This means that parts listed first will likely
  # receive more pennies than ones listed later.
  #
  # Pass [2, 1, 1] as input to give twice as much to part1 as part2 or
  # part3 which results in 50% of the cash to party1, 25% to part2, and 25% to part3. Passing a
  # number instead of an array will split the amount evenly (without losing pennies when rounding).
  #
  # @param [Array<Numeric>, Numeric] parts how amount should be distributed to parts
  #
  # @return [Array<Money>]
  #
  # @example
  #   Money.new(5,   "USD").allocate([3, 7]) #=> [Money.new(2), Money.new(3)]
  #   Money.new(100, "USD").allocate([1, 1, 1]) #=> [Money.new(34), Money.new(33), Money.new(33)]
  #   Money.new(100, "USD").allocate(2) #=> [Money.new(50), Money.new(50)]
  #   Money.new(100, "USD").allocate(3) #=> [Money.new(34), Money.new(33), Money.new(33)]
  #
  def allocate(parts)
    amounts = Money::Allocation.generate(fractional, parts, !Money.infinite_precision)
    amounts.map { |amount| self.class.new(amount, currency) }
  end
  alias_method :split, :allocate

  # Round the monetary amount to smallest unit of coinage.
  #
  # @note
  #   This method is only useful when operating with infinite_precision turned
  #   on. Without infinite_precision values are rounded to the smallest unit of
  #   coinage automatically.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(10.1, 'USD').round #=> Money.new(10, 'USD')
  #
  # @see
  #   Money.infinite_precision
  #
  def round(rounding_mode = self.class.rounding_mode, rounding_precision = 0)
    rounded_amount = as_d(@fractional).round(rounding_precision, rounding_mode)
    self.class.new(rounded_amount, currency, bank)
  end

  # Creates a formatted price string according to several rules.
  #
  # @param [Hash] rules See {Money::Formatter Money::Formatter} for the list of formatting options
  #
  # @return [String]
  #
  def format(*rules)
    Money::Formatter.new(self, *rules).to_s
  end

  # Returns a thousands separator according to the locale
  #
  # @return [String]
  #
  def thousands_separator
    (locale_backend && locale_backend.lookup(:thousands_separator, currency)) ||
      Money::Formatter::DEFAULTS[:thousands_separator]
  end

  # Returns a decimal mark according to the locale
  #
  # @return [String]
  #
  def decimal_mark
    (locale_backend && locale_backend.lookup(:decimal_mark, currency)) ||
      Money::Formatter::DEFAULTS[:decimal_mark]
  end

  private

  def as_d(num)
    if num.respond_to?(:to_d)
      num.is_a?(Rational) ? num.to_d(self.class.conversion_precision) : num.to_d
    else
      BigDecimal(num.to_s.empty? ? 0 : num.to_s)
    end
  end

  def return_value(value)
    if self.class.infinite_precision
      value
    else
      value.round(0, self.class.rounding_mode).to_i
    end
  end

  def locale_backend
    self.class.locale_backend
  end
end
