# encoding: utf-8
require 'money/bank/variable_exchange'

# Represents an amount of money in a given currency.
class Money
  include Comparable

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


  # Parses the current string and converts it to a +Money+ object.
  # Excess characters will be discarded.
  #
  # @param [String, #to_s] input The input to parse.
  # @param [Currency, String, Symbol] currency The currency format.
  #   The currency to set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @raise [ArgumentError] If any +currency+ is supplied and
  #   given value doesn't match the one extracted from
  #   the +input+ string.
  #
  # @example
  #   '100'.to_money                #=> #<Money @cents=10000>
  #   '100.37'.to_money             #=> #<Money @cents=10037>
  #   '100 USD'.to_money            #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   'USD 100'.to_money            #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   '$100 USD'.to_money           #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   'hello 2000 world'.to_money   #=> #<Money @cents=200000 @currency=#<Money::Currency id: usd>>
  #
  # @example Mismatching currencies
  #   'USD 2000'.to_money("EUR")    #=> ArgumentError
  #
  # @see Money.from_string
  #
  def self.parse(input, currency = nil)
    i = input.to_s

    # Get the currency.
    m = i.scan /([A-Z]{2,3})/
    c = m[0] ? m[0][0] : nil

    # check that currency passed and embedded currency are the same,
    # and negotiate the final currency
    if currency.nil? and c.nil?
      currency = Money.default_currency
    elsif currency.nil?
      currency = c
    elsif c.nil?
      currency = currency
    elsif currency != c
      # TODO: ParseError
      raise ArgumentError, "Mismatching Currencies"
    end
    currency = Money::Currency.wrap(currency)

    cents = extract_cents(i, currency)
    Money.new(cents, currency)
  end

  # Converts a String into a Money object treating the +value+
  # as dollars and converting them to the corresponding cents value,
  # according to +currency+ subunit property,
  # before instantiating the Money object.
  #
  # Behind the scenes, this method relies on {Money.from_bigdecimal}
  # to avoid problems with string-to-numeric conversion.
  #
  # @param [String, #to_s] value The money amount, in dollars.
  # @param [Currency, String, Symbol] currency
  #   The currency to set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @example
  #   Money.from_string("100")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_string("100", "USD")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_string("100", "EUR")
  #   #=> #<Money @cents=10000 @currency="EUR">
  #   Money.from_string("100", "BHD")
  #   #=> #<Money @cents=100 @currency="BHD">
  #
  # @see String#to_money
  # @see Money.parse
  #
  def self.from_string(value, currency = Money.default_currency)
    from_bigdecimal(BigDecimal.new(value.to_s), currency)
  end

  # Converts a Fixnum into a Money object treating the +value+
  # as dollars and converting them to the corresponding cents value,
  # according to +currency+ subunit property,
  # before instantiating the Money object.
  #
  # @param [Fixnum] value The money amount, in dollars.
  # @param [Currency, String, Symbol] currency The currency format.
  #
  # @return [Money]
  #
  # @example
  #   Money.from_fixnum(100)
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_fixnum(100, "USD")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_fixnum(100, "EUR")
  #   #=> #<Money @cents=10000 @currency="EUR">
  #   Money.from_fixnum(100, "BHD")
  #   #=> #<Money @cents=100 @currency="BHD">
  #
  # @see Fixnum#to_money
  # @see Money.from_numeric
  #
  def self.from_fixnum(value, currency = Money.default_currency)
    currency = Money::Currency.wrap(currency)
    amount   = value * currency.subunit_to_unit
    Money.new(amount, currency)
  end

  # Converts a Float into a Money object treating the +value+
  # as dollars and converting them to the corresponding cents value,
  # according to +currency+ subunit property,
  # before instantiating the Money object.
  #
  # Behind the scenes, this method relies on Money.from_bigdecimal
  # to avoid problems with floating point precision.
  #
  # @param [Float] value The money amount, in dollars.
  # @param [Currency, String, Symbol] currency The currency format.
  #
  # @return [Money]
  #
  # @example
  #   Money.from_float(100.0)
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_float(100.0, "USD")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_float(100.0, "EUR")
  #   #=> #<Money @cents=10000 @currency="EUR">
  #   Money.from_float(100.0, "BHD")
  #   #=> #<Money @cents=100 @currency="BHD">
  #
  # @see Float#to_money
  # @see Money.from_numeric
  #
  def self.from_float(value, currency = Money.default_currency)
    from_bigdecimal(BigDecimal.new(value.to_s), currency)
  end

  # Converts a BigDecimal into a Money object treating the +value+
  # as dollars and converting them to the corresponding cents value,
  # according to +currency+ subunit property,
  # before instantiating the Money object.
  #
  # @param [BigDecimal] value The money amount, in dollars.
  # @param [Currency, String, Symbol] currency The currency format.
  #
  # @return [Money]
  #
  # @example
  #   Money.from_bigdecimal(BigDecimal.new("100")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_bigdecimal(BigDecimal.new("100", "USD")
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_bigdecimal(BigDecimal.new("100", "EUR")
  #   #=> #<Money @cents=10000 @currency="EUR">
  #   Money.from_bigdecimal(BigDecimal.new("100", "BHD")
  #   #=> #<Money @cents=100 @currency="BHD">
  #
  # @see BigDecimal#to_money
  # @see Money.from_numeric
  #
  def self.from_bigdecimal(value, currency = Money.default_currency)
    currency = Money::Currency.wrap(currency)
    amount   = value * currency.subunit_to_unit
    Money.new(amount.fix, currency)
  end

  # Converts a Numeric value into a Money object treating the +value+
  # as dollars and converting them to the corresponding cents value,
  # according to +currency+ subunit property,
  # before instantiating the Money object.
  #
  # This method relies on various +Money.from_*+ methods
  # and tries to forwards the call to the most appropriate method
  # in order to reduce computation effort.
  # For instance, if +value+ is an Integer, this method calls
  # {Money.from_fixnum} instead of using the default
  # {Money.from_bigdecimal} which adds the overload to converts
  # the value into a slower BigDecimal instance.
  #
  # @param [Numeric] value The money amount, in dollars.
  # @param [Currency, String, Symbol] currency The currency format.
  #
  # @return [Money]
  #
  # @raise +ArgumentError+ Unless +value+ is a supported type.
  #
  # @example
  #   Money.from_numeric(100)
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_numeric(100.00)
  #   #=> #<Money @cents=10000 @currency="USD">
  #   Money.from_numeric("100")
  #   #=> ArgumentError
  #
  # @see Numeric#to_money
  # @see Money.from_fixnum
  # @see Money.from_float
  # @see Money.from_bigdecimal
  #
  def self.from_numeric(value, currency = Money.default_currency)
    case value
      when Fixnum
        from_fixnum(value, currency)
      when Numeric
        from_bigdecimal(BigDecimal.new(value.to_s), currency)
      else
        raise ArgumentError, "`value' should be a Numeric object"
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
    @cents = cents.round
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

  # Compares this money object against another object. +other_money+ must
  # respond to #to_money. Returns -1 when less than, 0 when equal and 1 when
  # greater than.
  #
  # If +other_money+ is a different currency, then +other_money+ will first be
  # converted into this money object's currency by calling +#exchange+ on
  # +other_money+.
  #
  # Comparisons against objects that do not respond to #to_money will cause an
  # +ArgumentError+ to be raised.
  #
  # @param [Money, #to_money] other_money Value to compare with.
  #
  # @return [-1, 0, 1]
  #
  # @raise [ArgumentError]
  #
  # @example
  #   Money.new(100) <=> 99             #=>  1
  #   Money.new(100) <=> Money.new(100) #=>  0
  #   Money.new(100) <=> "$101.00"      #=> -1
  def <=>(other_money)
    if other_money.respond_to?(:to_money)
      other_money = other_money.to_money
      if self.currency == other_money.currency
        cents <=> other_money.cents
      else
        cents <=> other_money.exchange_to(currency).cents
      end
    else
      raise ArgumentError, "Comparison of #{self.class} with #{other_money.inspect} failed"
    end
  end

  # Returns a new Money object containing the sum of the two operands' monetary
  # values. If +other_money+ has a different currency then its monetary value
  # is automatically exchanged to this object's currency using +exchange_to+.
  #
  # @param [Money] other_money Other +Money+ object to add.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100) + Money.new(100) #=> #<Money @cents=200>
  def +(other_money)
    if currency == other_money.currency
      Money.new(cents + other_money.cents, other_money.currency)
    else
      Money.new(cents + other_money.exchange_to(currency).cents, currency)
    end
  end

  # Returns a new Money object containing the difference between the two
  # operands' monetary values. If +other_money+ has a different currency then
  # its monetary value is automatically exchanged to this object's currency
  # using +exchange_to+.
  #
  # @param [Money] other_money Other +Money+ object to subtract.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100) - Money.new(99) #=> #<Money @cents=1>
  def -(other_money)
    if currency == other_money.currency
      Money.new(cents - other_money.cents, other_money.currency)
    else
      Money.new(cents - other_money.exchange_to(currency).cents, currency)
    end
  end

  # Multiplies the monetary value with the given number and returns a new
  # +Money+ object with this monetary value and the same currency.
  #
  # Note that you can't multiply a Money object by an other +Money+ object.
  #
  # @param [Numeric] value Number to multiply by.
  #
  # @return [Money] The resulting money.
  #
  # @raise [ArgumentError] If +value+ is a Money instance.
  #
  # @example
  #   Money.new(100) * 2 #=> #<Money @cents=200>
  #
  def *(value)
    if value.is_a?(Money)
      raise ArgumentError, "Can't multiply a Money by a Money"
    else
      Money.new(cents * value, currency)
    end
  end

  # Divides the monetary value with the given number and returns a new +Money+
  # object with this monetary value and the same currency.
  # Can also divide by another +Money+ object to get a ratio.
  #
  # +Money/Numeric+ returns +Money+. +Money/Money+ returns +Float+.
  #
  # @param [Money, Numeric] value Number to divide by.
  #
  # @return [Money] The resulting money if you divide Money by a number.
  # @return [Float] The resulting number if you divide Money by a Money.
  #
  # @example
  #   Money.new(100) / 10            #=> #<Money @cents=10>
  #   Money.new(100) / Money.new(10) #=> 10.0
  #
  def /(value)
    if value.is_a?(Money)
      if currency == value.currency
        (cents / BigDecimal.new(value.cents.to_s)).to_f
      else
        (cents / BigDecimal(value.exchange_to(currency).cents.to_s)).to_f
      end
    else
      Money.new(cents / value, currency)
    end
  end

  # Synonym for +#/+.
  #
  # @param [Money, Numeric] value Number to divide by.
  #
  # @return [Money] The resulting money if you divide Money by a number.
  # @return [Float] The resulting number if you divide Money by a Money.
  #
  # @see #/
  #
  def div(value)
    self / value
  end

  # Divide money by money or fixnum and return array containing quotient and
  # modulus.
  #
  # @param [Money, Fixnum] val Number to divmod by.
  #
  # @return [Array<Money,Money>,Array<Fixnum,Money>]
  #
  # @example
  #   Money.new(100).divmod(9)            #=> [#<Money @cents=11>, #<Money @cents=1>]
  #   Money.new(100).divmod(Money.new(9)) #=> [11, #<Money @cents=1>]
  def divmod(val)
    if val.is_a?(Money)
      a = self.cents
      b = self.currency == val.currency ? val.cents : val.exchange_to(self.currency).cents
      q, m = a.divmod(b)
      return [q, Money.new(m, self.currency)]
    else
      return [self.div(val), Money.new(self.cents.modulo(val), self.currency)]
    end
  end

  # Equivalent to +self.divmod(val)[1]+
  #
  # @param [Money, Fixnum] val Number take modulo with.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100).modulo(9)            #=> #<Money @cents=1>
  #   Money.new(100).modulo(Money.new(9)) #=> #<Money @cents=1>
  def modulo(val)
    self.divmod(val)[1]
  end

  # Synonym for +#modulo+.
  #
  # @param [Money, Fixnum] val Number take modulo with.
  #
  # @return [Money]
  #
  # @see #modulo
  def %(val)
    self.modulo(val)
  end

  # If different signs +self.modulo(val) - val+ otherwise +self.modulo(val)+
  #
  # @param [Money, Fixnum] val Number to rake remainder with.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(100).remainder(9) #=> #<Money @cents=1>
  def remainder(val)
    a, b = self, val
    b = b.exchange_to(a.currency) if b.is_a?(Money) and a.currency != b.currency

    a_sign, b_sign = :pos, :pos
    a_sign = :neg if a.cents < 0
    b_sign = :neg if (b.is_a?(Money) and b.cents < 0) or (b < 0)

    return a.modulo(b) if a_sign == b_sign
    a.modulo(b) - (b.is_a?(Money) ? b : Money.new(b, a.currency))
  end

  # Return absolute value of self as a new Money object.
  #
  # @return [Money]
  #
  # @example
  #   Money.new(-100).abs #=> #<Money @cents=100>
  def abs
    Money.new(self.cents.abs, self.currency)
  end

  # Test if the money amount is zero.
  #
  # @return [Boolean]
  #
  # @example
  #   Money.new(100).zero? #=> false
  #   Money.new(0).zero?   #=> true
  def zero?
    cents == 0
  end

  # Test if the money amount is non-zero. Returns this money object if it is
  # non-zero, or nil otherwise, like +Numeric#nonzero?+.
  #
  # @return [Money, nil]
  #
  # @example
  #   Money.new(100).nonzero? #=> #<Money @cents=100>
  #   Money.new(0).nonzero?   #=> nil
  def nonzero?
    cents != 0 ? self : nil
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

  # If I18n is loaded, looks up key +:number.format.delimiter+.
  # Otherwise and as fallback it uses +Currency#delimiter+.
  # If +nil+ is returned, default to ",".
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, "USD").delimiter #=> ","
  if Object.const_defined?("I18n")
    def delimiter
      I18n.t(:"number.format.delimiter", :default => currency.delimiter || ",")
    end
  else
    def delimiter
      currency.delimiter || ","
    end
  end

  # If I18n is loaded, looks up key +:number.format.seperator+.
  # Otherwise and as fallback it uses +Currency#seperator+.
  # If +nil+ is returned, default to ",".
  #
  # @return [String]
  #
  # @example
  #   Money.new(100, "USD").separator #=> "."
  if Object.const_defined?("I18n")
    def separator
      I18n.t(:"number.format.separator", :default => currency.separator || ".")
    end
  else
    def separator
      currency.separator || "."
    end
  end

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
  # @option *rules [Boolean, String, nil] :separator (true) Whether the
  #  currency should be separated by the specified character or '.'
  #
  # @example
  #   # If a string is specified, it's value is used.
  #   Money.new(100, "USD").format(:separator => ",") #=> "$1,00"
  #
  #   # If the separator for a given currency isn't known, then it will default
  #   # to "." as separator.
  #   Money.new(100, "FOO").format #=> "$1.00"
  #
  # @option *rules [Boolean, String, nil] :delimiter (true) Whether the
  #  currency should be delimited by the specified character or ','
  #
  # @example
  #   # If false is specified, no delimiter is used.
  #   Money.new(100000, "USD").format(:delimiter => false) #=> "1000.00"
  #   Money.new(100000, "USD").format(:delimiter => nil)   #=> "1000.00"
  #   Money.new(100000, "USD").format(:delimiter => "")    #=> "1000.00"
  #
  #   # If a string is specified, it's value is used.
  #   Money.new(100000, "USD").format(:delimiter => ".") #=> "$1.000.00"
  #
  #   # If the delimiter for a given currency isn't known, then it will default
  #   # to "," as delimiter.
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

    if rules.has_key?(:symbol)
      if rules[:symbol] === true
        symbol_value = symbol
      elsif rules[:symbol]
        symbol_value = rules[:symbol]
      else
        symbol_value = ""
      end
    else
      symbol_value = symbol
    end

    formatted = case rules[:no_cents]
                when true
                  "#{symbol_value}#{self.to_s.to_i}"
                else
                  "#{symbol_value}#{self.to_s}"
                end
    if rules.has_key?(:separator) and rules[:separator] and
      rules[:separator] != separator
      formatted.sub!(separator, rules[:separator])
    end

    delimiter_value = delimiter
    # Determine delimiter
    if rules.has_key?(:delimiter)
      if rules[:delimiter] === false or rules[:delimiter].nil?
        delimiter_value = ""
      elsif rules[:delimiter]
        delimiter_value = rules[:delimiter]
      end
    end

    # Apply delimiter
    formatted.gsub!(/(\d)(?=(?:\d{3})+(?:\.|,|$))(\d{3}\..*)?/, "\\1#{delimiter_value}\\2")

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
    decimal_places = if currency.subunit_to_unit == 1
                       0
                     elsif currency.subunit_to_unit % 10 == 0
                       Math.log10(currency.subunit_to_unit).to_s.to_i
                     else
                       Math.log10(currency.subunit_to_unit).to_s.to_i+1
                     end
    unit, subunit  = cents.abs.divmod(currency.subunit_to_unit).map{|o| o.to_s}
    unit = (unit.to_i * -1).to_s if cents < 0
    return unit if decimal_places == 0
    subunit = (("0" * decimal_places) + subunit)[(-1*decimal_places)..-1]
    "#{unit}#{separator}#{subunit}"
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
    rules
  end

  # Takes a number string and attempts to massage out the number.
  #
  # @param [String] input The string containing a potential number.
  #
  # @return [Integer]
  #
  def self.extract_cents(input, currency = Money.default_currency)
    # remove anything that's not a number, potential delimiter, or minus sign
    num = input.gsub(/[^\d|\.|,|\'|\s|\-]/, '').strip

    # set a boolean flag for if the number is negative or not
    negative = num.split(//).first == "-"

    # if negative, remove the minus sign from the number
    num = num.gsub(/^-/, '') if negative

    # gather all separators within the result number
    used_separators = num.scan /[^\d]/

    # determine the number of unique separators within the number
    #
    # e.g.
    # $1,234,567.89 would return 2 (, and .)
    # $125,00 would return 1
    # $199 would return 0
    # $1 234,567.89 would raise an error (separators are space, comma, and period)
    case used_separators.uniq.length
    # no separator or delimiter; major (dollars) is the number, and minor (cents) is 0
    when 0 then major, minor = num, 0

    # two separators, so we know the last item in this array is the
    # major/minor delimiter and the rest are separators
    when 2
      separator, delimiter = used_separators.uniq
      # remove all separators, split on the delimiter
      major, minor = num.gsub(separator, '').split(delimiter)
      min = 0 unless min
    when 1
      # we can't determine if the comma or period is supposed to be a separator or a delimiter
      # e.g.
      # 1,00 - comma is a delimiter
      # 1.000 - period is a delimiter
      # 1,000 - comma is a separator
      # 1,000,000 - comma is a separator
      # 10000,00 - comma is a delimiter
      # 1000,000 - comma is a delimiter

      # assign first separator for reusability
      separator = used_separators.first

      # separator is used as a separator when there are multiple instances, always
      if num.scan(separator).length > 1 # multiple matches; treat as separator
        major, minor = num.gsub(separator, ''), 0
      else
        # ex: 1,000 - 1.0000 - 10001.000
        # split number into possible major (dollars) and minor (cents) values
        possible_major, possible_minor = num.split(separator)
        possible_major ||= "0"
        possible_minor ||= "00"

        # if the minor (cents) length isn't 3, assign major/minor from the possibles
        # e.g.
        #   1,00 => 1.00
        #   1.0000 => 1.00
        #   1.2 => 1.20
        if possible_minor.length != 3 # delimiter
          major, minor = possible_major, possible_minor
        else
          # minor length is three
          # let's try to figure out intent of the delimiter

          # the major length is greater than three, which means
          # the comma or period is used as a delimiter
          # e.g.
          #   1000,000
          #   100000,000
          if possible_major.length > 3
            major, minor = possible_major, possible_minor
          else
            # number is in format ###{sep}### or ##{sep}### or #{sep}###
            # handle as , is sep, . is delimiter
            if separator == '.'
              major, minor = possible_major, possible_minor
            else
              major, minor = "#{possible_major}#{possible_minor}", 0
            end
          end
        end
      end
    else
      # TODO: ParseError
      raise ArgumentError, "Invalid currency amount"
    end

    # build the string based on major/minor since separator/delimiters have been removed
    # avoiding floating point arithmetic here to ensure accuracy
    cents = (major.to_i * currency.subunit_to_unit)
    # Because of an bug in JRuby, we can't just call #floor
    decimal_places = Math.log10(currency.subunit_to_unit).to_s.to_i
    minor = minor.to_s
    minor = if minor.size < decimal_places
              (minor + ("0" * decimal_places))[0,decimal_places].to_i
            elsif minor.size > decimal_places
              if minor[decimal_places,1].to_i >= 5
                minor[0,decimal_places].to_i+1
              else
                minor[0,decimal_places].to_i
              end
            else
              minor.to_i
            end
    cents += minor

    # if negative, multiply by -1; otherwise, return positive cents
    negative ? cents * -1 : cents
  end

end
