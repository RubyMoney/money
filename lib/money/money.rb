require 'money/variable_exchange_bank'

# Represents an amount of money in a certain currency.
class Money
  include Comparable
  
  attr_reader :cents, :currency, :bank
  
  class << self
    # Each Money object is associated to a bank object, which is responsible
    # for currency exchange. This property allows one to specify the default
    # bank object.
    #
    #   bank1 = MyBank.new
    #   bank2 = MyOtherBank.new
    #   
    #   Money.default_bank = bank1
    #   money1 = Money.new(10)
    #   money1.bank  # => bank1
    #   
    #   Money.default_bank = bank2
    #   money2 = Money.new(10)
    #   money2.bank  # => bank2
    #   money1.bank  # => bank1
    #
    # The default value for this property is an instance if VariableExchangeBank.
    # It allows one to specify custom exchange rates:
    #
    #   Money.default_bank.add_rate("USD", "CAD", 1.24515)
    #   Money.default_bank.add_rate("CAD", "USD", 0.803115)
    #   Money.us_dollar(100).exchange_to("CAD")  # => Money.ca_dollar(124)
    #   Money.ca_dollar(100).exchange_to("USD")  # => Money.us_dollar(80)
    attr_accessor :default_bank
    
    # The default currency, which is used when <tt>Money.new</tt> is called
    # without an explicit currency argument. The default value is "USD".
    attr_accessor :default_currency
  end
  
  self.default_bank = VariableExchangeBank.instance
  self.default_currency = "USD"
  
  
  # Create a new money object with value 0.
  def self.empty(currency = default_currency)
    Money.new(0, currency)
  end

  # Creates a new Money object of the given value, using the Canadian dollar currency.
  def self.ca_dollar(cents)
    Money.new(cents, "CAD")
  end

  # Creates a new Money object of the given value, using the American dollar currency.
  def self.us_dollar(cents)
    Money.new(cents, "USD")
  end
  
  # Creates a new Money object of the given value, using the Euro currency.
  def self.euro(cents)
    Money.new(cents, "EUR")
  end
  
  def self.add_rate(from_currency, to_currency, rate)
    Money.default_bank.add_rate(from_currency, to_currency, rate)
  end
  
  
  # Creates a new money object. 
  #  Money.new(100) 
  # 
  # Alternativly you can use the convinience methods like 
  # Money.ca_dollar and Money.us_dollar 
  def initialize(cents, currency = Money.default_currency, bank = Money.default_bank)
    @cents = cents.round
    @currency = currency
    @bank = bank
  end

  # Do two money objects equal? Only works if both objects are of the same currency
  def ==(other_money)
    cents == other_money.cents && bank.same_currency?(currency, other_money.currency)
  end

  def <=>(other_money)
    if bank.same_currency?(currency, other_money.currency)
      cents <=> other_money.cents
    else
      cents <=> other_money.exchange_to(currency).cents
    end
  end

  def +(other_money)
    if currency == other_money.currency
      Money.new(cents + other_money.cents, other_money.currency)
    else
      Money.new(cents + other_money.exchange_to(currency).cents,currency)
    end   
  end

  def -(other_money)
    if currency == other_money.currency
      Money.new(cents - other_money.cents, other_money.currency)
    else
      Money.new(cents - other_money.exchange_to(currency).cents, currency)
    end   
  end

  # get the cents value of the object
  def cents
    @cents
  end

  # multiply money by fixnum
  def *(fixnum)
    Money.new(cents * fixnum, currency)    
  end

  # divide money by fixnum
  def /(fixnum)
    Money.new(cents / fixnum, currency)    
  end
  
  # Test if the money amount is zero
  def zero?
    cents == 0 
  end


  # Format the price according to several rules
  # Currently supported are :with_currency, :no_cents and :html
  #
  # with_currency: 
  #
  #  Money.ca_dollar(0).format => "free"
  #  Money.ca_dollar(100).format => "$1.00"
  #  Money.ca_dollar(100).format(:with_currency) => "$1.00 CAD"
  #  Money.us_dollar(85).format(:with_currency) => "$0.85 USD"
  #
  # no_cents:  
  #
  #  Money.ca_dollar(100).format(:no_cents) => "$1"
  #  Money.ca_dollar(599).format(:no_cents) => "$5"
  #  
  #  Money.ca_dollar(570).format(:no_cents, :with_currency) => "$5 CAD"
  #  Money.ca_dollar(39000).format(:no_cents) => "$390"
  #
  # html:
  #
  #  Money.ca_dollar(570).format(:html, :with_currency) =>  "$5.70 <span class=\"currency\">CAD</span>"
  def format(*rules)
    return "free" if cents == 0

    rules = rules.flatten

    if rules.include?(:no_cents)
      formatted = sprintf("$%d", cents.to_f / 100  )          
    else
      formatted = sprintf("$%.2f", cents.to_f / 100  )      
    end

    if rules.include?(:with_currency)
      formatted << " "
      formatted << '<span class="currency">' if rules.include?(:html)
      formatted << currency
      formatted << '</span>' if rules.include?(:html)
    end
    formatted
  end
  
  # Money.ca_dollar(100).to_s => "1.00"
  def to_s
    sprintf("%.2f", cents / 100.00)
  end
  
  # Recieve the amount of this money object in another currency.
  def exchange_to(other_currency)
    Money.new(@bank.exchange(self.cents, currency, other_currency), other_currency)
  end  
  
  # Recieve a money object with the same amount as the current Money object
  # in american dollar 
  def as_us_dollar
    exchange_to("USD")
  end
  
  # Recieve a money object with the same amount as the current Money object
  # in canadian dollar 
  def as_ca_dollar
    exchange_to("CAD")
  end
  
  # Recieve a money object with the same amount as the current Money object
  # in euro
  def as_euro
    exchange_to("EUR")
  end
  
  # Conversation to self
  def to_money
    self
  end  
end
