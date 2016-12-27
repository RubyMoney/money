# encoding: utf-8
require "bigdecimal"
require "bigdecimal/util"
require "set"
require "i18n"

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
  require "money/formatter/to_string"
  autoload :V6Compatibility, "money/v6_compatibility"

  extend ClassAttribute
  include CurrencyMethods
  include Comparable
  include Allocate
  include Arithmetic

  # Raised when smallest denomination of a currency is not defined
  class UndefinedSmallestDenomination < StandardError; end

  # Class Methods
  class << self
    def default_currency=(val)
      block =
        if val.respond_to?(:call)
          val
        else
          val = Currency.new(val)
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

    # Parses decimal and rounds it according to currency and default settings.
    def prepare_d(value, currency)
      value =
        if value.respond_to?(:to_d)
          value.is_a?(Rational) ? value.to_d(conversion_precision) : value.to_d
        else
          BigDecimal.new(value.to_s)
        end
      if infinite_precision
        value
      else
        value.round(currency.decimal_places, rounding_mode)
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
      default_bank.add_rate(from_currency, to_currency, rate)
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

    # Creates a new Money object of value given in the +subunit+ of the given
    # +currency+.
    #
    # @param [Numeric] amount The numerical value of the money.
    # @param [Currency, String, Symbol] currency The currency format.
    # @param [Money::Bank::*] bank The exchange bank to use.
    #
    # @example
    #   Money.from_subunits(2345, "USD") # => #<Money amount:23.45 currency:USD>
    #   Money.from_subunits(2345, "JPY") # => #<Money amount:2345 currency:JPY>
    #
    # @return [Money]
    #
    # @see #initialize
    def from_subunits(amount, currency = default_currency, bank = default_bank)
      raise ArgumentError, '`amount` must have #to_d' unless amount.respond_to?(:to_d)
      currency = Currency.wrap(currency)
      value = amount.to_d / currency.subunit_to_unit
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
  self.default_currency = -> { Currency.new(:USD) }

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
  self.formatter = Formatter

  # Creates a new Money object of value given with amount of +units+ of
  # the given +currency+.
  #
  # Alternatively you can use the convenience
  # methods like {Money.ca_dollar} and {Money.us_dollar}.
  #
  # @param [Object] obj Either the fractional value of the money,
  #   a Money object, or a currency.
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
  def initialize(val, currency = nil, bank = nil)
    @currency =
      if currency
        Currency.wrap(currency)
      else
        val.respond_to?(:currency) ? val.currency : self.class.default_currency
      end
    @amount   = val.respond_to?(:amount) ? val.amount : self.class.prepare_d(val, @currency)
    @bank     = bank || (val.respond_to?(:bank) ? val.bank : self.class.default_bank)
  end

  def yaml_initialize(_tag, attrs)
    initialize(attrs['amount'] || 0, attrs['currency'], attrs['bank'])
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
    value = to_d * currency.subunit_to_unit
    if self.class.infinite_precision
      value
    else
      value.round(0, self.class.rounding_mode).to_i
    end
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
    smallest_denomination = currency.smallest_denomination
    value = (to_d / smallest_denomination).
      round(currency.decimal_places, self.class.rounding_mode)
    value * smallest_denomination
  end

  # @!attribute [r] currency
  #   @return [Currency] The money's currency.
  # @!attribute [r] bank
  #   @return [Money::Bank::Base] The +Money::Bank+-based object which currency
  #     exchanges are performed with.
  attr_reader :currency, :bank, :amount
  alias_method :to_d, :amount

  # Returns a Fixnum hash value based on the +fractional+ and +currency+ attributes
  # in order to use functions like & (intersection), group_by, etc.
  #
  # @return [Fixnum]
  #
  # @example
  #   Money.new(100).hash #=> 908351
  def hash
    [to_d.hash, currency.hash].hash
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
    "#<#{self.class.name} amount:#{to_d.to_s('F')} currency:#{currency}>"
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

  # Conversation to +self+.
  #
  # @return [self]
  def to_money(new_currency = nil)
    new_currency ? exchange_to(new_currency) : self
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
      build_new(to_d.round(currency.decimal_places, rounding_mode), currency)
    else
      self
    end
  end

  # Formats value using formatter. Default formatter is +Money.formatter+ which is
  # +Money::Formatter+ by default.
  def format(formatter = self.class.formatter, **options)
    formatter.format(self, options)
  end

  # Returns the amount of money as a string.
  #
  # @return [String]
  #
  # @example
  #   Money.ca_dollar(100).to_s #=> "1.00"
  def to_s
    Formatter::ToString.format(self)
  end

  private

  # Used only for v6 compatibility. Should be replaced with inline `self.class.new`
  # after this compatibility is dropped.
  def build_new(*args)
    self.class.new(*args)
  end
end
