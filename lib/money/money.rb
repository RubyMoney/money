# encoding: utf-8
require "money/bank/variable_exchange"
require "money/bank/single_currency"
require "money/money/arithmetic"
require "money/money/constructors"
require "money/money/formatting"

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
  include Comparable, Money::Arithmetic, Money::Formatting
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
  # For example, in the US Dollar currency the fractional unit is cents, and
  # there are 100 cents in one US Dollar. So given the Money representation of
  # one US dollar, the fractional interpretation is 100.
  #
  # Another example is that of the Kuwaiti Dinar. In this case the fractional
  # unit is the Fils and there 1000 Fils to one Kuwaiti Dinar. So given the
  # Money representation of one Kuwaiti Dinar, the fractional interpretation is
  # 1000.
  #
  # @return [Integer] when infinite_precision is false
  # @return [BigDecimal] when infintie_precision is true
  #
  # @see infinite_precision
  def fractional
    # Ensure we have a BigDecimal. If the Money object is created
    # from YAML, @fractional can end up being set to a Float.
    fractional = as_d(@fractional)

    return_value(fractional)
  end

  # Round a given amount of money to the nearest possible amount in cash value. For
  # example, in Swiss francs (CHF), the smallest possible amount of cash value is
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
    #   @return [Money::Bank::Base] Each Money object is associated to a bank
    #     object, which is responsible for currency exchange. This property
    #     allows you to specify the default bank object. The default value for
    #     this property is an instance of +Bank::VariableExchange.+ It allows
    #     one to specify custom exchange rates.
    #
    # @!attribute default_formatting_rules
    #   @return [Hash] Use this to define a default hash of rules for everytime
    #     +Money#format+ is called.  Rules provided on method call will be
    #     merged with the default ones.  To overwrite a rule, just provide the
    #     intended value while calling +format+.
    #
    #   @see +Money::Formatting#format+ for more details.
    #
    #   @example
    #     Money.default_formatting_rules = { :display_free => true }
    #     Money.new(0, "USD").format                          # => "free"
    #     Money.new(0, "USD").format(:display_free => false)  # => "$0.00"
    #
    # @!attribute [rw] use_i18n
    #   @return [Boolean] Use this to disable i18n even if it's used by other
    #     objects in your app.
    #
    # @!attribute [rw] infinite_precision
    #   @return [Boolean] Use this to enable infinite precision cents
    #
    # @!attribute [rw] conversion_precision
    #   @return [Fixnum] Use this to specify precision for converting Rational
    #     to BigDecimal
    attr_accessor :default_bank, :default_formatting_rules,
      :use_i18n, :infinite_precision, :conversion_precision

    # @attr_writer rounding_mode Use this to specify the rounding mode
    #
    # @!attribute default_currency
    #   @return [Money::Currency] The default currency, which is used when
    #     +Money.new+ is called without an explicit currency argument. The
    #     default value is Currency.new("USD"). The value must be a valid
    #     +Money::Currency+ instance.
    attr_writer :rounding_mode, :default_currency

  end

  def self.default_currency
    if @default_currency.respond_to?(:call)
      Money::Currency.new(@default_currency.call)
    else
      Money::Currency.new(@default_currency)
    end
  end

  def self.setup_defaults
    # Set the default bank for creating new +Money+ objects.
    self.default_bank = Bank::VariableExchange.instance

    # Set the default currency for creating new +Money+ object.
    self.default_currency = Currency.new("USD")

    # Default to using i18n
    self.use_i18n = true

    # Default to not using infinite precision cents
    self.infinite_precision = false

    # Default to bankers rounding
    self.rounding_mode = BigDecimal::ROUND_HALF_EVEN

    # Default the conversion of Rationals precision to 16
    self.conversion_precision = 16
  end

  def self.inherited(base)
    base.setup_defaults
  end

  setup_defaults

  # Use this to return the rounding mode.  You may also pass a
  # rounding mode and a block to temporatly change it.  It will
  # then return the results of the block instead.
  #
  # @param [BigDecimal::ROUND_MODE] mode
  #
  # @return [BigDecimal::ROUND_MODE,Yield] rounding mode or block results
  #
  # @example
  #   fee = Money.rounding_mode(BigDecimal::ROUND_HALF_UP) do
  #     Money.new(1200) * BigDecimal.new('0.029')
  #   end
  def self.rounding_mode(mode=nil)
    if mode.nil?
      Thread.current[:money_rounding_mode] || @rounding_mode
    else
      begin
        Thread.current[:money_rounding_mode] = mode
        yield
      ensure
        Thread.current[:money_rounding_mode] = nil
      end
    end
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
    Numeric === amount or raise ArgumentError, "'amount' must be numeric"
    currency = Currency.wrap(currency)
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
    @fractional = obj.respond_to?(:fractional) ? obj.fractional : as_d(obj)
    @currency   = obj.respond_to?(:currency) ? obj.currency : Currency.wrap(currency)
    @currency ||= Money.default_currency
    @bank       = obj.respond_to?(:bank) ? obj.bank : bank
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
  #   Money.new(1_00, "USD").dollars   # => BigDecimal.new("1.00")
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
  #   Money.new(1_00, "USD").amount    # => BigDecimal.new("1.00")
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
    @currency = Currency.wrap(val)
  end

  # Returns a Fixnum hash value based on the +fractional+ and +currency+ attributes
  # in order to use functions like & (intersection), group_by, etc.
  #
  # @return [Fixnum]
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
    unit, subunit, fraction = strings_from_fractional

    str = if currency.decimal_places == 0
            if fraction == ""
              unit
            else
              "#{unit}#{decimal_mark}#{fraction}"
            end
          else
            "#{unit}#{decimal_mark}#{pad_subunit(subunit)}#{fraction}"
          end

    fractional < 0 ? "-#{str}" : str
  end

  # Return the amount of money as a BigDecimal.
  #
  # @return [BigDecimal]
  #
  # @example
  #   Money.us_dollar(1_00).to_d #=> BigDecimal.new("1.00")
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

  # Conversation to +self+.
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
  # in american dollars.
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
  # in canadian dollar.
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

  # Allocates money between different parties without losing pennies.
  # After the mathmatically split has been performed, left over pennies will
  # be distributed round-robin amongst the parties. This means that parties
  # listed first will likely recieve more pennies then ones that are listed later
  #
  # @param [Array<Numeric>] splits [0.50, 0.25, 0.25] to give 50% of the cash to party1, 25% to party2, and 25% to party3.
  #
  # @return [Array<Money>]
  #
  # @example
  #   Money.new(5,   "USD").allocate([0.3, 0.7])         #=> [Money.new(2), Money.new(3)]
  #   Money.new(100, "USD").allocate([0.33, 0.33, 0.33]) #=> [Money.new(34), Money.new(33), Money.new(33)]
  #
  def allocate(splits)
    allocations = allocations_from_splits(splits)

    if (allocations - BigDecimal("1")) > Float::EPSILON
      raise ArgumentError, "splits add to more then 100%"
    end

    amounts, left_over = amounts_from_splits(allocations, splits)

    unless self.class.infinite_precision
      left_over.to_i.times { |i| amounts[i % amounts.length] += 1 }
    end

    amounts.collect { |fractional| self.class.new(fractional, currency) }
  end

  # Split money amongst parties evenly without losing pennies.
  #
  # @param [Numeric] num number of parties.
  #
  # @return [Array<Money>]
  #
  # @example
  #   Money.new(100, "USD").split(3) #=> [Money.new(34), Money.new(33), Money.new(33)]
  def split(num)
    raise ArgumentError, "need at least one party" if num < 1

    if self.class.infinite_precision
      split_infinite(num)
    else
      split_flat(num)
    end
  end

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
  def round(rounding_mode = self.class.rounding_mode)
    if self.class.infinite_precision
      self.class.new(fractional.round(0, rounding_mode), self.currency)
    else
      self
    end
  end

  private

  def as_d(num)
    if num.respond_to?(:to_d)
      num.is_a?(Rational) ? num.to_d(self.class.conversion_precision) : num.to_d
    else
      BigDecimal.new(num.to_s)
    end
  end

  def strings_from_fractional
    unit, subunit = fractional().abs.divmod(currency.subunit_to_unit)

    if self.class.infinite_precision
      strings_for_infinite_precision(unit, subunit)
    else
      strings_for_base_precision(unit, subunit)
    end
  end

  def strings_for_infinite_precision(unit, subunit)
    subunit, fraction = subunit.divmod(BigDecimal("1"))
    fraction = fraction.to_s("F")[2..-1] # want fractional part "0.xxx"
    fraction = "" if fraction =~ /^0+$/

    [unit.to_i.to_s, subunit.to_i.to_s, fraction]
  end

  def strings_for_base_precision(unit, subunit)
    [unit.to_s, subunit.to_s, ""]
  end

  def pad_subunit(subunit)
    cnt = currency.decimal_places
    padding = "0" * cnt
    "#{padding}#{subunit}"[-1 * cnt, cnt]
  end

  def allocations_from_splits(splits)
    splits.inject(0) { |sum, n| sum + as_d(n) }
  end

  def amounts_from_splits(allocations, splits)
    left_over = fractional

    amounts = splits.map do |ratio|
      if self.class.infinite_precision
        fractional * ratio
      else
        (fractional * ratio / allocations).floor.tap do |frac|
          left_over -= frac
        end
      end
    end

    [amounts, left_over]
  end

  def split_infinite(num)
    amt = div(as_d(num))
    1.upto(num).map{amt}
  end

  def split_flat(num)
    low = self.class.new(fractional / num, currency)
    high = self.class.new(low.fractional + 1, currency)

    remainder = fractional % num

    Array.new(num).each_with_index.map do |_, index|
      index < remainder ? high : low
    end
  end

  def return_value(value)
    if self.class.infinite_precision
      value
    else
      value.round(0, self.class.rounding_mode).to_i
    end
  end
end
