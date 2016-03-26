# encoding: utf-8
require "bigdecimal"
require "bigdecimal/util"
require "set"
require "i18n"
require "sixarm_ruby_unaccent"
require "money/unaccent"

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
  require "money/class_attribute"
  require "money/currency"
  require "money/bank/variable_exchange"
  require "money/bank/single_currency"
  require "money/currency_methods"
  require "money/allocate"
  require "money/arithmetic"
  require "money/formatter"
  require "money/to_string"

  extend ClassAttribute
  include CurrencyMethods
  include Comparable
  include Allocate
  include Arithmetic
  include ToString

  # Raised when smallest denomination of a currency is not defined
  class UndefinedSmallestDenomination < StandardError; end

  # Class Methods
  class << self
    def default_currency=(val)
      block =
        if val.respond_to?(:call)
          -> { Money::Currency.new(val.call) }
        else
          val = Money::Currency.new(val)
          -> { val }
        end
      define_singleton_method(:default_currency, &block)
    end

    # Use this to return the rounding mode.  You may also pass a
    # rounding mode and a block to temporarily change it.  It will
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
    def rounding_mode(mode = nil)
      if mode.nil?
        Thread.current[:money_rounding_mode] || _rounding_mode
      else
        begin
          prev = Thread.current[:money_rounding_mode]
          Thread.current[:money_rounding_mode] = mode
          yield
        ensure
          Thread.current[:money_rounding_mode] = prev
          Thread.current[:money_rounding_mode] = nil
        end
      end
    end

    def round_d(value)
      if infinite_precision
        value
      else
        # TODO: why to_i? change specs.
        value.round(0, rounding_mode).to_i
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
    def add_rate(from_currency, to_currency, rate)
      Money.default_bank.add_rate(from_currency, to_currency, rate)
    end

    # Sets the default bank to be a SingleCurrency bank that raises on
    # currency exchange. Useful when apps operate in a single currency at a time.
    def disallow_currency_conversion!
      self.default_bank = Bank::SingleCurrency.instance
    end

    # Create a new money object with value 0.
    #
    # @param [Currency, String, Symbol] currency The currency to use.
    #
    # @return [Money]
    #
    # @example
    #   Money.empty #=> #<Money @fractional=0>
    def empty(currency = default_currency)
      @empty ||= {}
      @empty[currency] ||= new(0, currency).freeze
    end
    alias_method :zero, :empty

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
    def from_amount(amount, currency = default_currency, bank = default_bank)
      Numeric === amount or raise ArgumentError, "'amount' must be numeric"
      currency = Currency.wrap(currency)
      value = amount.to_d * currency.subunit_to_unit
      value = value.round(0, rounding_mode) unless infinite_precision
      new(value, currency, bank)
    end
  end

  # @!attribute [rw] default_bank
  #   @return [Money::Bank::Base] Each Money object is associated to a bank
  #     object, which is responsible for currency exchange. This property
  #     allows you to specify the default bank object. The default value for
  #     this property is an instance of +Bank::VariableExchange.+ It allows
  #     one to specify custom exchange rates.
  class_attribute :default_bank
  self.default_bank = Bank::VariableExchange.instance

  # @!attribute default_currency
  #   @return [Money::Currency] The default currency, which is used when
  #     +Money.new+ is called without an explicit currency argument. The
  #     default value is Currency.new("USD"). The value must be a valid
  #     +Money::Currency+ instance.
  # Set the default currency for creating new +Money+ object.
  self.default_currency = Currency.new('USD')

  # @!attribute [rw] infinite_precision
  #   @return [Boolean] Use this to enable infinite precision cents
  class_attribute :infinite_precision
  self.infinite_precision = false

  #
  class_attribute :_rounding_mode
  singleton_class.send :alias_method, :rounding_mode=, :_rounding_mode=
  # Default to bankers rounding
  self.rounding_mode = BigDecimal::ROUND_HALF_EVEN

  # @!attribute [rw] conversion_precision
  # Default the conversion of Rationals precision to 16
  #
  #   @return [Fixnum] Use this to specify precision for converting Rational
  #     to BigDecimal
  class_attribute :conversion_precision
  self.conversion_precision = 16

  # @!attribute [rw] conversion_precision
  # Default formatter to use in #fromat. By default +Money::Formatter+ is used.
  class_attribute :formatter
  self.formatter = Money::Formatter

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

    self.class.round_d(fractional)
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
    unless currency.smallest_denomination
      raise UndefinedSmallestDenomination, 'Smallest denomination of this currency is not defined'
    end

    fractional = as_d(@fractional)
    smallest_denomination = as_d(currency.smallest_denomination)
    rounded_value = (fractional / smallest_denomination).round(0, self.class.rounding_mode) *
      smallest_denomination

    self.class.round_d(rounded_value)
  end

  # @!attribute [r] currency
  #   @return [Currency] The money's currency.
  # @!attribute [r] bank
  #   @return [Money::Bank::Base] The +Money::Bank+-based object which currency
  #     exchanges are performed with.
  attr_reader :currency, :bank

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
    if given_currency.nil? || currency == given_currency
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
    if currency == other_currency
      self
    else
      bank.exchange_with(self, other_currency, &rounding_method)
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
      self.class.new(fractional.round(0, rounding_mode), currency)
    else
      self
    end
  end

  # Formats value using formatter. Default formatter is +Money.formatter+ which is
  # +Money::Formatter+ by default.
  def format(formatter = self.class.formatter, **options)
    formatter.format(self, options)
  end

  private

  def as_d(num)
    if num.respond_to?(:to_d)
      num.is_a?(Rational) ? num.to_d(self.class.conversion_precision) : num.to_d
    else
      BigDecimal.new(num.to_s)
    end
  end
end
