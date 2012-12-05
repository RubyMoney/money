# encoding: utf-8
require "money/bank/variable_exchange"
require "money/money/arithmetic"
require "money/money/parsing"
require "money/money/formatting"

# Represents an amount of money in a given currency.
class Money
  include Comparable
  include Arithmetic
  include Formatting
  include Parsing

  # Convenience method for fractional part of the amount. Synonym of #fractional
  #
  # @return [Integer]
  def cents
    fractional
  end

  # The value of the amount represented in the fractional unit of the currency. Example: USD, 1 dollar (amount) == 100 cents (fractional unit).
  #
  # @return [Integer]
  def fractional
    if self.class.infinite_precision
      @fractional
    else
      # If the Money object is created from a serialized YAML string, 
      # @fractional can end up being set to a Float. We need to ensure 
      # it is BigDecimal before calling #round with two paramers. 
      # Float class only provides #round with 0 or 1 parameter.
      BigDecimal.new(@fractional.to_s, 0).round(0, self.class.rounding_mode).to_i
    end
  end

  # The currency the money is in.
  #
  # @return [Currency]
  attr_reader :currency

  # The +Money::Bank+ based object used to perform currency exchanges with.
  #
  # @return [Money::Bank::*]
  attr_reader :bank

  # Class Methods
  class << self
    # Each Money object is associated to a bank object, which is responsible
    # for currency exchange. This property allows you to specify the default
    # bank object. The default value for this property is an instance of
    # +Bank::VariableExchange.+ It allows one to specify custom exchange rates.
    #
    # @return [Money::Bank::*]
    attr_accessor :default_bank

    # The default currency, which is used when +Money.new+ is called without an
    # explicit currency argument. The default value is Currency.new("USD"). The
    # value must be a valid +Money::Currency+ instance.
    #
    # @return [Money::Currency]
    attr_accessor :default_currency

    # Use this to disable i18n even if it's used by other objects in your app.
    #
    # @return [true,false]
    attr_accessor :use_i18n

    # Use this to enable the ability to assume the currency from a passed symbol
    #
    # @return [true,false]
    attr_accessor :assume_from_symbol

    # Use this to enable infinite precision cents
    #
    # @return [true,false]
    attr_accessor :infinite_precision

    # Use this to specify the rounding mode
    #
    # @return [BigDecimal::ROUND_MODE]
    attr_accessor :rounding_mode

    # Use this to specify precision for converting Rational to BigDecimal
    #
    # @return [Integer]
    attr_accessor :conversion_precision
  end

  # Set the default bank for creating new +Money+ objects.
  self.default_bank = Bank::VariableExchange.instance

  # Set the default currency for creating new +Money+ object.
  self.default_currency = Currency.new("USD")

  # Default to using i18n
  self.use_i18n = true

  # Default to not using currency symbol assumptions when parsing
  self.assume_from_symbol = false

  # Default to not using infinite precision cents
  self.infinite_precision = false

  # Default to bankers rounding
  self.rounding_mode = BigDecimal::ROUND_HALF_EVEN

  # Default the conversion of Rationals precision to 16
  self.conversion_precision = 16

  # Create a new money object with value 0.
  #
  # @param [Currency, String, Symbol] currency The currency to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.empty #=> #<Money @fractional=0>
  def self.empty(currency = default_currency)
    Money.new(0, currency)
  end

  # Creates a new Money object of the given value, using the Canadian
  # dollar currency.
  #
  # @param [Integer] cents The cents value.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.ca_dollar(100)
  #   n.cents    #=> 100
  #   n.currency #=> #<Money::Currency id: cad>
  def self.ca_dollar(cents)
    Money.new(cents, "CAD")
  end

  # Creates a new Money object of the given value, using the American dollar
  # currency.
  #
  # @param [Integer] cents The cents value.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.us_dollar(100)
  #   n.cents    #=> 100
  #   n.currency #=> #<Money::Currency id: usd>
  def self.us_dollar(cents)
    Money.new(cents, "USD")
  end

  # Creates a new Money object of the given value, using the Euro currency.
  #
  # @param [Integer] cents The cents value.
  #
  # @return [Money]
  #
  # @example
  #   n = Money.euro(100)
  #   n.cents    #=> 100
  #   n.currency #=> #<Money::Currency id: eur>
  def self.euro(cents)
    Money.new(cents, "EUR")
  end

  # Creates a new Money object of +amount+ value ,
  # with given +currency+.
  #
  # The amount value is expressed in the main monetary unit,
  # opposite to the subunit-based representation
  # used internally by this library called +cents+.
  #
  # @param [Numeric] amount The money amount, in main monetary unit.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.new_with_amount(100)
  #   #=> #<Money @fractional=10000 @currency="USD">
  #   Money.new_with_amount(100, "USD")
  #   #=> #<Money @fractional=10000 @currency="USD">
  #   Money.new_with_amount(100, "EUR")
  #   #=> #<Money @fractional=10000 @currency="EUR">
  #
  # @see Money.new
  #
  def self.new_with_amount(amount, currency = Money.default_currency, bank = Money.default_bank)
    money = from_numeric(amount, currency)
    # Hack! You can't change a bank
    money.instance_variable_set("@bank", bank)
    money
  end

  # Synonym of #new_with_amount
  #
  # @see Money.new_with_amount
  def self.new_with_dollars(*args)
    self.new_with_amount(*args)
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


  # Creates a new Money object of value given in the 
  # +fractional unit+ of the given +currency+.
  #
  # Alternatively you can use the convenience
  # methods like {Money.ca_dollar} and {Money.us_dollar}.
  #
  # @param [Integer] The value given in the fractional unit.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100)
  #   #=> #<Money @fractional=100 @currency="USD">
  #   Money.new(100, "USD")
  #   #=> #<Money @fractional=100 @currency="USD">
  #   Money.new(100, "EUR")
  #   #=> #<Money @fractional=100 @currency="EUR">
  #
  # @see Money.new_with_dollars
  #
  def initialize(fractional, currency = Money.default_currency, bank = Money.default_bank)
    @fractional = if fractional.is_a?(Rational)
                    fractional.to_d(self.class.conversion_precision)
                  elsif fractional.respond_to?(:to_d)
                    fractional.to_d
                  else
                    BigDecimal.new(fractional.to_s)
                  end
    @currency = Currency.wrap(currency)
    @bank     = bank
  end

  # Assuming using a currency using dollars:
  # Returns the value of the money in dollars,
  # instead of in the fractional unit cents.
  #
  # Synonym of #amount
  #
  # @return [Float]
  #
  # @example
  #   Money.new(100).dollars           # => 1.0
  #   Money.new_with_dollars(1).dollar # => 1.0
  #
  # @see #amount
  # @see #to_f
  # @see #cents
  #
  def dollars
    amount
  end

  # Returns the numerical value of the money
  #
  # @return [Float]
  #
  # @example
  #   Money.new(100).amount            # => 1.0
  #   Money.new_with_amount(1).amount  # => 1.0
  #
  # @see #to_f
  # @see #fractional
  #
  def amount
    to_f
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
    "#<Money fractional:#{fractional} currency:#{currency}>"
  end

  # Returns the amount of money as a string.
  #
  # @return [String]
  #
  # @example
  #   Money.ca_dollar(100).to_s #=> "1.00"
  def to_s
    unit, subunit = fractional().abs.divmod(currency.subunit_to_unit)

    unit_str       = ""
    subunit_str    = ""
    fraction_str   = ""

    if self.class.infinite_precision
      subunit, fraction = subunit.divmod(BigDecimal("1"))

      unit_str       = unit.to_i.to_s
      subunit_str    = subunit.to_i.to_s
      fraction_str   = fraction.to_s("F")[2..-1] # want fractional part "0.xxx"

      fraction_str = "" if fraction_str =~ /^0+$/
    else
      unit_str, subunit_str = unit.to_s, subunit.to_s
    end

    absolute_str = if currency.decimal_places == 0
      if fraction_str == ""
        unit_str
      else
        "#{unit_str}#{decimal_mark}#{fraction_str}"
      end
    else
      # need to pad subunit to right position,
      # for example 1 usd 3 cents should be 1.03 not 1.3
      subunit_str.insert(0, '0') while subunit_str.length < currency.decimal_places

      "#{unit_str}#{decimal_mark}#{subunit_str}#{fraction_str}"
    end

    absolute_str.tap do |str|
      str.insert(0, "-") if fractional() < 0
    end
  end

  # Return the amount of money as a BigDecimal.
  #
  # @return [BigDecimal]
  #
  # @example
  #   Money.us_dollar(100).to_d => BigDecimal.new("1.0")
  def to_d
    BigDecimal.new(fractional.to_s) / BigDecimal.new(currency.subunit_to_unit.to_s)
  end

  # Return the amount of money as a float. Floating points cannot guarantee
  # precision. Therefore, this function should only be used when you no longer
  # need to represent currency or working with another system that requires
  # decimals.
  #
  # @return [Float]
  #
  # @example
  #   Money.us_dollar(100).to_f => 1.0
  def to_f
    to_d.to_f
  end

  # Conversation to +self+.
  #
  # @return [self]
  def to_money(given_currency = nil)
    given_currency = Currency.wrap(given_currency) if given_currency
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
  # @return [Money]
  #
  # @example
  #   Money.new(2000, "USD").exchange_to("EUR")
  #   Money.new(2000, "USD").exchange_to(Currency.new("EUR"))
  def exchange_to(other_currency)
    other_currency = Currency.wrap(other_currency)
    @bank.exchange_with(self, other_currency)
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

  # Allocates money between different parties without loosing pennies.
  # After the mathmatically split has been performed, left over pennies will
  # be distributed round-robin amongst the parties. This means that parties
  # listed first will likely recieve more pennies then ones that are listed later
  #
  # @param [0.50, 0.25, 0.25] to give 50% of the cash to party1, 25% ot party2, and 25% to party3.
  #
  # @return [Array<Money, Money, Money>]
  #
  # @example
  #   Money.new(5, "USD").allocate([0.3,0.7)) #=> [Money.new(2), Money.new(3)]
  #   Money.new(100, "USD").allocate([0.33,0.33,0.33]) #=> [Money.new(34), Money.new(33), Money.new(33)]
  def allocate(splits)
    allocations = splits.inject(BigDecimal("0")) do |sum, n|
      n = BigDecimal(n.to_s) unless n.is_a?(BigDecimal)
      sum + n
    end

    if (allocations - BigDecimal("1")) > Float::EPSILON
      raise ArgumentError, "splits add to more then 100%"
    end

    left_over = fractional

    amounts = splits.map do |ratio|
      if self.class.infinite_precision
        fraction = fractional * ratio
      else
        fraction = (fractional * ratio / allocations).floor
        left_over -= fraction
        fraction
      end
    end

    unless self.class.infinite_precision
      left_over.to_i.times { |i| amounts[i % amounts.length] += 1 }
    end

    amounts.collect { |fractional| Money.new(fractional, currency) }
  end

  # Split money amongst parties evenly without loosing pennies.
  #
  # @param [2] number of parties.
  #
  # @return [Array<Money, Money, Money>]
  #
  # @example
  #   Money.new(100, "USD").split(3) #=> [Money.new(34), Money.new(33), Money.new(33)]
  def split(num)
    raise ArgumentError, "need at least one party" if num < 1

    if self.class.infinite_precision
      amt = self.div(BigDecimal(num.to_s))
      return 1.upto(num).map{amt}
    end

    low = Money.new(fractional / num, self.currency)
    high = Money.new(low.fractional + 1, self.currency)

    remainder = fractional % num
    result = []

    num.times do |index|
      result[index] = index < remainder ? high : low
    end

    result
  end

end
