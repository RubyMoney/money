# encoding: utf-8

require 'json'

class Money

  # Represents a specific currency unit.
  class Currency
    include Comparable

    require "money/currency/loader"
    extend  Loader

    require "money/currency/heuristics"
    extend  Heuristics

    # Thrown when an unknown currency is requested.
    class UnknownCurrency < StandardError; end

    class << self

      # Lookup a currency with given +id+ an returns a +Currency+ instance on
      # success, +nil+ otherwise.
      #
      # @param [String, Symbol, #to_s] id Used to look into +table+ and
      # retrieve the applicable attributes.
      #
      # @return [Money::Currency]
      #
      # @example
      #   Money::Currency.find(:eur) #=> #<Money::Currency id: eur ...>
      #   Money::Currency.find(:foo) #=> nil
      def find(id)
        id = id.to_s.downcase.to_sym
        new(id) if self.table[id]
      end

      # Lookup a currency with given +num+ as an ISO 4217 numeric and returns an
      # +Currency+ instance on success, +nil+ otherwise.
      #
      # @param [#to_s] num used to look into +table+ in +iso_numeric+ and find
      # the right currency id.
      #
      # @return [Money::Currency]
      #
      # @example
      #   Money::Currency.find_by_iso_numeric(978) #=> #<Money::Currency id: eur ...>
      #   Money::Currency.find_by_iso_numeric('001') #=> nil
      def find_by_iso_numeric(num)
        num = num.to_s
        id, garbage = self.table.find{|key, currency| currency[:iso_numeric] == num}
        new(id) if self.table[id]
      end

      # Wraps the object in a +Currency+ unless it's already a +Currency+
      # object.
      #
      # @param [Object] object The object to attempt and wrap as a +Currency+
      # object.
      #
      # @return [Money::Currency]
      #
      # @example
      #   c1 = Money::Currency.new(:usd)
      #   Money::Currency.wrap(nil)   #=> nil
      #   Money::Currency.wrap(c1)    #=> #<Money::Currency id: usd ...>
      #   Money::Currency.wrap("usd") #=> #<Money::Currency id: usd ...>
      def wrap(object)
        if object.nil?
          nil
        elsif object.is_a?(Currency)
          object
        else
          Currency.new(object)
        end
      end

      # List of known currencies.
      #
      # == monetary unit
      # The standard unit of value of a currency, as the dollar in the United States or the peso in Mexico.
      # http://www.answers.com/topic/monetary-unit
      # == fractional monetary unit, subunit
      # A monetary unit that is valued at a fraction (usually one hundredth) of the basic monetary unit
      # http://www.answers.com/topic/fractional-monetary-unit-subunit
      #
      # See http://en.wikipedia.org/wiki/List_of_circulating_currencies and
      # http://search.cpan.org/~tnguyen/Locale-Currency-Format-1.28/Format.pm
      def table
        @table ||= load_currencies
      end

      # We need a string-based validator before creating an unbounded number of symbols.
      # http://www.randomhacks.net/articles/2007/01/20/13-ways-of-looking-at-a-ruby-symbol#11
      # https://github.com/RubyMoney/money/issues/132
      def stringified_keys
        @stringified_keys ||= stringify_keys
      end

      def register(curr)
        key = curr[:iso_code].downcase.to_sym
        @table[key] = curr
        @stringified_keys = stringify_keys
      end

      private

      def stringify_keys
        table.keys.map{|k| k.to_s.downcase}
      end
    end

    # The symbol used to identify the currency, usually the lowercase
    # +iso_code+ attribute.
    #
    # @return [Symbol]
    attr_reader :id

    # A numerical value you can use to sort/group the currency list.
    #
    # @return [Integer]
    attr_reader :priority

    # The international 3-letter code as defined by the ISO 4217 standard.
    #
    # @return [String]
    attr_reader :iso_code
    #
    # The international 3-numeric code as defined by the ISO 4217 standard.
    #
    # @return [String]
    attr_reader :iso_numeric

    # The currency name.
    #
    # @return [String]
    attr_reader :name

    # The currency symbol (UTF-8 encoded).
    #
    # @return [String]
    attr_reader :symbol

    # The html entity for the currency symbol
    #
    # @return [String]
    attr_reader :html_entity

    # The name of the fractional monetary unit.
    #
    # @return [String]
    attr_reader :subunit

    # The proportion between the unit and the subunit
    #
    # @return [Integer]
    attr_reader :subunit_to_unit

    # The number of digits after the decimal separator.
    #
    # @return [Float]
    attr_reader :exponent

    # The decimal mark, or character used to separate the whole unit from the subunit.
    #
    # @return [String]
    attr_reader :decimal_mark
    alias :separator :decimal_mark

    # The character used to separate thousands grouping of the whole unit.
    #
    # @return [String]
    attr_reader :thousands_separator
    alias :delimiter :thousands_separator

    # Should the currency symbol precede the amount, or should it come after?
    #
    # @return [boolean]
    attr_reader :symbol_first

    # Create a new +Currency+ object.
    #
    # @param [String, Symbol, #to_s] id Used to look into +table+ and retrieve
    #  the applicable attributes.
    #
    # @return [Money::Currency]
    #
    # @example
    #   Money::Currency.new(:usd) #=> #<Money::Currency id: usd ...>
    def initialize(id)
      id = id.to_s.downcase
      raise(UnknownCurrency, "Unknown currency `#{id}'") unless self.class.stringified_keys.include?(id)

      @id  = id.to_sym
      data = self.class.table[@id]
      data.each_pair do |key, value|
        instance_variable_set(:"@#{key}", value)
      end
    end

    # Compares +self+ with +other_currency+ against the value of +priority+
    # attribute.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [-1,0,1] -1 if less than, 0 is equal to, 1 if greater than
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1 <=> c2 #=> 1
    #   c2 <=> c1 #=> -1
    #   c1 <=> c1 #=> 0
    def <=>(other_currency)
      self.priority <=> other_currency.priority
    end

    # Compares +self+ with +other_currency+ and returns +true+ if the are the
    # same or if their +id+ attributes match.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [Boolean]
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1 == c1 #=> true
    #   c1 == c2 #=> false
    def ==(other_currency)
      self.equal?(other_currency) ||
      self.id == other_currency.id
    end

    # Compares +self+ with +other_currency+ and returns +true+ if the are the
    # same or if their +id+ attributes match.
    #
    # @param [Money::Currency] other_currency The currency to compare to.
    #
    # @return [Boolean]
    #
    # @example
    #   c1 = Money::Currency.new(:usd)
    #   c2 = Money::Currency.new(:jpy)
    #   c1.eql? c1 #=> true
    #   c1.eql? c2 #=> false
    def eql?(other_currency)
      self == other_currency
    end

    # Returns a Fixnum hash value based on the +id+ attribute in order to use
    # functions like & (intersection), group_by, etc.
    #
    # @return [Fixnum]
    #
    # @example
    #   Money::Currency.new(:usd).hash #=> 428936
    def hash
      id.hash
    end

    # Returns a human readable representation.
    #
    # @return [String]
    #
    # @example
    #   Money::Currency.new(:usd) #=> #<Currency id: usd ...>
    def inspect
      "#<#{self.class.name} id: #{id}, priority: #{priority}, symbol_first: #{symbol_first}, thousands_separator: #{thousands_separator}, html_entity: #{html_entity}, decimal_mark: #{decimal_mark}, name: #{name}, symbol: #{symbol}, subunit_to_unit: #{subunit_to_unit}, exponent: #{exponent}, iso_code: #{iso_code}, iso_numeric: #{iso_numeric}, subunit: #{subunit}>"
    end

    # Returns a string representation corresponding to the upcase +id+
    # attribute.
    #
    # -–
    # DEV: id.to_s.upcase corresponds to iso_code but don't use ISO_CODE for consistency.
    #
    # @return [String]
    #
    # @example
    #   Money::Currency.new(:usd).to_s #=> "USD"
    #   Money::Currency.new(:eur).to_s #=> "EUR"
    def to_s
      id.to_s.upcase
    end

    # Conversation to +self+.
    #
    # @return [self]
    def to_currency
      self
    end


    # Returns currency symbol or iso code for currencies with no symbol.
    #
    # @return [String]
    def code
      symbol || iso_code
    end

    def symbol_first?
      !!@symbol_first
    end

    # Returns the number of digits after the decimal separator.
    #
    # @return [Float]
    def exponent
      Math.log10(@subunit_to_unit)
    end

    # Cache decimal places for subunit_to_unit values.  Common ones pre-cached.
    def self.decimal_places_cache
      @decimal_places_cache ||= {
        1 => 0,
        10 => 1,
        100 => 2,
        1000 => 3
      }
    end

    # The number of decimal places needed.
    #
    # @return [Integer]
    def decimal_places
      cache = self.class.decimal_places_cache
      places  = cache[subunit_to_unit]
      unless places
        places = calculate_decimal_places(subunit_to_unit)
        cache[subunit_to_unit] = places
      end
      places
    end

    # If we need to figure out how many decimal places we need we
    # use repeated integer division.
    def calculate_decimal_places(num)
      return 0 if num == 1
      i = 1
      while num >= 10
        num /= 10
        i += 1 if num >= 10
      end
      i
    end
    private :calculate_decimal_places

  end
end
