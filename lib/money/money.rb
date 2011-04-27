# encoding: utf-8
require 'money/bank/variable_exchange'
require 'money/money/arithmetic'
require 'money/money/parsing'

# Represents an amount of money in a given currency.
class Money
  include Comparable
  include Arithmetic
  extend Parsing

  # The value of the money in cents.
  #
  # @return [Integer]
  attr_reader :cents

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
    # bank object. The default value for this property is an instance if
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
  end

  # Set the default bank for creating new +Money+ objects.
  self.default_bank = Bank::VariableExchange.instance

  # Set the default currency for creating new +Money+ object.
  self.default_currency = Currency.new("USD")

  # Create a new money object with value 0.
  #
  # @param [Currency, String, Symbol] currency The currency to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.empty #=> #<Money @cents=0>
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


  # Creates a new Money object of +amount+ value in dollars,
  # with given +currency+.
  #
  # The amount value is expressed in +dollars+
  # where the +dollar+ is the main monetary unit,
  # opposite to the subunit-based representation
  # used internally by this library called +cents+.
  #
  # @param [Numeric] amount The money amount, in dollars.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.new_with_dollars(100)
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.new_with_dollars(100, "USD")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.new_with_dollars(100, "EUR")
  #   #=> #<Money @cents=10000 @currency="EUR">
  #
  # @see Money.new
  #
  def self.new_with_dollars(amount, currency = Money.default_currency, bank = Money.default_bank)
    money = from_numeric(amount, currency)
    # Hack! You can't change a bank
    money.instance_variable_set("@bank", bank)
    money
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


  # Creates a new Money object of +cents+ value in cents,
  # with given +currency+.
  #
  # Alternatively you can use the convenience
  # methods like {Money.ca_dollar} and {Money.us_dollar}.
  #
  # @param [Integer] cents The money amount, in cents.
  # @param [Currency, String, Symbol] currency The currency format.
  # @param [Money::Bank::*] bank The exchange bank to use.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100)
  #   #=> #<Money @cents=100 @currency="USD">
  #   Money.new(100, "USD")
  #   #=> #<Money @cents=100 @currency="USD">
  #   Money.new(100, "EUR")
  #   #=> #<Money @cents=100 @currency="EUR">
  #
  # @see Money.new_with_dollars
  #
  def initialize(cents, currency = Money.default_currency, bank = Money.default_bank)
    @cents = cents.round.to_i
    @currency = Currency.wrap(currency)
    @bank = bank
  end

  # Returns the value of the money in dollars,
  # instead of in cents.
  #
  # @return [Float]
  #
  # @example
  #   Money.new(100).dollars           # => 1.0
  #   Money.new_with_dollars(1).dollar # => 1.0
  #
  # @see #to_f
  # @see #cents
  #
  def dollars
    to_f
  end

  # Return string representation of currency object
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, :USD).currency_as_string #=> "USD"
  def currency_as_string
    self.currency.to_s
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

  # Checks whether two money objects have the same currency and the same
  # amount. Checks against money objects with a different currency and checks
  # against objects that do not respond to #to_money will always return false.
  #
  # @param [Money] other_money Value to compare with.
  #
  # @return [Boolean]
  #
  # @example
  #   Money.new(100) == Money.new(101) #=> false
  #   Money.new(100) == Money.new(100) #=> true
  def ==(other_money)
    if other_money.respond_to?(:to_money)
      other_money = other_money.to_money
      cents == other_money.cents && self.currency == other_money.currency
    else
      false
    end
  end

  # Synonymous with +#==+.
  #
  # @param [Money] other_money Value to compare with.
  #
  # @return [Money]
  #
  # @see #==
  def eql?(other_money)
    self == other_money
  end

  # Returns a Fixnum hash value based on the +cents+ and +currency+ attributes
  # in order to use functions like & (intersection), group_by, etc.
  #
  # @return [Fixnum]
  #
  # @example
  #   Money.new(100).hash #=> 908351
  def hash
    [cents.hash, currency.hash].hash
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

  # If I18n is loaded, looks up key +:number.currency.format.delimiter+.
  # Otherwise and as fallback it uses +Currency#thousands_separator+.
  # If +nil+ is returned, default to ",".
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, "USD").thousands_separator #=> ","
  if Object.const_defined?("I18n")
    def thousands_separator
      I18n.t(
        :"number.currency.format.delimiter",
        :default => I18n.t(
          :"number.format.delimiter",
          :default => (currency.thousands_separator || ",")
        )
      )
    end
  else
    def thousands_separator
      currency.thousands_separator || ","
    end
  end
  alias :delimiter :thousands_separator

  # If I18n is loaded, looks up key +:number.currency.format.separator+.
  # Otherwise and as fallback it uses +Currency#decimal_mark+.
  # If +nil+ is returned, default to ",".
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, "USD").decimal_mark #=> "."
  if Object.const_defined?("I18n")
    def decimal_mark
      I18n.t(
        :"number.currency.format.separator",
        :default => I18n.t(
          :"number.format.separator",
          :default => (currency.decimal_mark || ".")
        )
      )
    end
  else
    def decimal_mark
      currency.decimal_mark || "."
    end
  end
  alias :separator :decimal_mark

  # Creates a formatted price string according to several rules.
  #
  # @param [Hash] *rules The options used to format the string.
  #
  # @return [String]
  #
  # @option *rules [Boolean, String] :display_free (false) Whether a zero
  #  amount of money should be formatted of "free" or as the supplied string.
  #
  # @example
  #   Money.us_dollar(0).format(:display_free => true)     #=> "free"
  #   Money.us_dollar(0).format(:display_free => "gratis") #=> "gratis"
  #   Money.us_dollar(0).format                            #=> "$0.00"
  #
  # @option *rules [Boolean] :with_currency (false) Whether the currency name
  #  should be appended to the result string.
  #
  # @example
  #   Money.ca_dollar(100).format => "$1.00"
  #   Money.ca_dollar(100).format(:with_currency => true) #=> "$1.00 CAD"
  #   Money.us_dollar(85).format(:with_currency => true)  #=> "$0.85 USD"
  #
  # @option *rules [Boolean] :no_cents (false) Whether cents should be omitted.
  #
  # @example
  #   Money.ca_dollar(100).format(:no_cents => true) #=> "$1"
  #   Money.ca_dollar(599).format(:no_cents => true) #=> "$5"
  #
  # @option *rules [Boolean, String, nil] :symbol (true) Whether a money symbol
  #  should be prepended to the result string. The default is true. This method
  #  attempts to pick a symbol that's suitable for the given currency.
  #
  # @example
  #   Money.new(100, "USD") #=> "$1.00"
  #   Money.new(100, "GBP") #=> "£1.00"
  #   Money.new(100, "EUR") #=> "€1.00"
  #
  #   # Same thing.
  #   Money.new(100, "USD").format(:symbol => true) #=> "$1.00"
  #   Money.new(100, "GBP").format(:symbol => true) #=> "£1.00"
  #   Money.new(100, "EUR").format(:symbol => true) #=> "€1.00"
  #
  #   # You can specify a false expression or an empty string to disable
  #   # prepending a money symbol.
  #   Money.new(100, "USD").format(:symbol => false) #=> "1.00"
  #   Money.new(100, "GBP").format(:symbol => nil)   #=> "1.00"
  #   Money.new(100, "EUR").format(:symbol => "")    #=> "1.00"
  #
  #   # If the symbol for the given currency isn't known, then it will default
  #   # to "¤" as symbol.
  #   Money.new(100, "AWG").format(:symbol => true) #=> "¤1.00"
  #
  #   # You can specify a string as value to enforce using a particular symbol.
  #   Money.new(100, "AWG").format(:symbol => "ƒ") #=> "ƒ1.00"
  #
  # @option *rules [Boolean, String, nil] :decimal_mark (true) Whether the
  #  currency should be separated by the specified character or '.'
  #
  # @example
  #   # If a string is specified, it's value is used.
  #   Money.new(100, "USD").format(:decimal_mark => ",") #=> "$1,00"
  #
  #   # If the decimal_mark for a given currency isn't known, then it will default
  #   # to "." as decimal_mark.
  #   Money.new(100, "FOO").format #=> "$1.00"
  #
  # @option *rules [Boolean, String, nil] :thousands_separator (true) Whether
  #  the currency should be delimited by the specified character or ','
  #
  # @example
  #   # If false is specified, no thousands_separator is used.
  #   Money.new(100000, "USD").format(:thousands_separator => false) #=> "1000.00"
  #   Money.new(100000, "USD").format(:thousands_separator => nil)   #=> "1000.00"
  #   Money.new(100000, "USD").format(:thousands_separator => "")    #=> "1000.00"
  #
  #   # If a string is specified, it's value is used.
  #   Money.new(100000, "USD").format(:thousands_separator => ".") #=> "$1.000.00"
  #
  #   # If the thousands_separator for a given currency isn't known, then it will
  #   # default to "," as thousands_separator.
  #   Money.new(100000, "FOO").format #=> "$1,000.00"
  #
  # @option *rules [Boolean] :html (false) Whether the currency should be
  #  HTML-formatted. Only useful in combination with +:with_currency+.
  #
  # @example
  #   s = Money.ca_dollar(570).format(:html => true, :with_currency => true)
  #   s #=>  "$5.70 <span class=\"currency\">CAD</span>"
  def format(*rules)
    # support for old format parameters
    rules = normalize_formatting_rules(rules)

    if cents == 0
      if rules[:display_free].respond_to?(:to_str)
        return rules[:display_free]
      elsif rules[:display_free]
        return "free"
      end
    end

    symbol_value =
      if rules.has_key?(:symbol)
        if rules[:symbol] === true
          symbol
        elsif rules[:symbol]
          rules[:symbol]
        else
          ""
        end
      elsif rules[:html]
        currency.html_entity
      else
        symbol
      end

    formatted = case rules[:no_cents]
                when true
                  "#{self.to_s.to_i}"
                else
                  "#{self.to_s}"
                end

    symbol_position =
      if rules.has_key?(:symbol_position)
        rules[:symbol_position]
      elsif currency.symbol_first?
        :before
      else
        :after
      end

    if symbol_value && !symbol_value.empty?
      formatted = (symbol_position == :before ? "#{symbol_value}#{formatted}" : "#{formatted} #{symbol_value}")
    end

    if rules.has_key?(:decimal_mark) and rules[:decimal_mark] and
      rules[:decimal_mark] != decimal_mark
      formatted.sub!(decimal_mark, rules[:decimal_mark])
    end

    thousands_separator_value = thousands_separator
    # Determine thousands_separator
    if rules.has_key?(:thousands_separator)
      if rules[:thousands_separator] === false or rules[:thousands_separator].nil?
        thousands_separator_value = ""
      elsif rules[:thousands_separator]
        thousands_separator_value = rules[:thousands_separator]
      end
    end

    # Apply thousands_separator
    formatted.gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/, "\\1#{thousands_separator_value}")

    if rules[:with_currency]
      formatted << " "
      formatted << '<span class="currency">' if rules[:html]
      formatted << currency.to_s
      formatted << '</span>' if rules[:html]
    end
    formatted
  end

  # Returns the amount of money as a string.
  #
  # @return [String]
  #
  # @example
  #   Money.ca_dollar(100).to_s #=> "1.00"
  def to_s
    unit, subunit  = cents.abs.divmod(currency.subunit_to_unit).map{|o| o.to_s}
    if currency.decimal_places == 0
      return "-#{unit}" if cents < 0
      return unit
    end
    subunit = (("0" * currency.decimal_places) + subunit)[(-1*currency.decimal_places)..-1]
    return "-#{unit}#{decimal_mark}#{subunit}" if cents < 0
    "#{unit}#{decimal_mark}#{subunit}"
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
    (BigDecimal.new(cents.to_s) / currency.subunit_to_unit).to_f
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

  # Conversation to +self+.
  #
  # @return [self]
  def to_money
    self
  end

  # Common inspect function
  #
  # @return [String]
  def inspect
    "#<Money cents:#{cents} currency:#{currency}>"
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
    allocations = splits.inject(0.0) {|sum, i| sum += i }
    raise ArgumentError, "splits add to more then 100%" if (allocations - 1.0) > Float::EPSILON

    left_over = cents

    amounts = splits.collect do |ratio|
      fraction = (cents * ratio / allocations).floor
      left_over -= fraction
      fraction
    end

    left_over.times { |i| amounts[i % amounts.length] += 1 }

    return amounts.collect { |cents| Money.new(cents, currency) }
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
    low = Money.new(cents / num)
    high = Money.new(low.cents + 1)

    remainder = cents % num
    result = []

    num.times do |index|
      result[index] = index < remainder ? high : low
    end

    return result
  end

  private

  # Cleans up formatting rules.
  #
  # @param [Hash]
  #
  # @return [Hash]
  def normalize_formatting_rules(rules)
    if rules.size == 0
      rules = {}
    elsif rules.size == 1
      rules = rules.pop
      rules = { rules => true } if rules.is_a?(Symbol)
    end
    if not rules.include?(:decimal_mark) and rules.include?(:separator)
      rules[:decimal_mark] = rules[:separator]
    end
    if not rules.include?(:thousands_separator) and rules.include?(:delimiter)
      rules[:thousands_separator] = rules[:delimiter]
    end
    rules
  end

end
