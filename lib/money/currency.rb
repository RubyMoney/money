# encoding: utf-8

require "json"
require "money/currency/loader"

class Money

  # Represents a specific currency unit.
  #
  # @see http://en.wikipedia.org/wiki/Currency
  # @see http://iso4217.net/
  class Currency
    include Comparable
    extend Enumerable

    autoload :Heuristics, 'money/currency/heuristics'

    # Keeping cached instances in sync between threads
    @@monitor = Monitor.new

    # Thrown when an unknown currency is requested.
    class UnknownCurrency < ArgumentError; end

    class << self
      def new(code)
        code = prepare_code(code)
        instances[code] || synchronize { instances[code] ||= super }
      end

      def instances
        @instances ||= {}
      end

      def synchronize(&block)
        @@monitor.synchronize(&block)
      end

      # Lookup a currency with given +code+ an returns a +Currency+ instance on
      # success, +nil+ otherwise.
      #
      # @param [String, Symbol, #to_s] code Used to look into +table+ and
      # retrieve the applicable attributes.
      #
      # @return [Money::Currency]
      #
      # @example
      #   Money::Currency.find(:eur) #=> #<Money::Currency id: eur ...>
      #   Money::Currency.find(:foo) #=> nil
      def find(code)
        new(code)
      rescue UnknownCurrency
        nil
      end

      # Bypasses call to Heuristics module, so it can be lazily loaded.
      def analyze(str)
        Heuristics.analyze(str, self)
      end

      # Lookup a currency with given +num+ as an ISO 4217 numeric and returns an
      # +Currency+ instance on success, +nil+ otherwise.
      #
      # @param [#to_s] num used to look into +table+ in +iso_numeric+ and find
      # the right currency code.
      #
      # @return [Money::Currency]
      #
      # @example
      #   Money::Currency.find_by_iso_numeric(978) #=> #<Money::Currency id: eur ...>
      #   Money::Currency.find_by_iso_numeric('001') #=> nil
      def find_by_iso_numeric(num)
        num = num.to_i
        code, _ = table.find { |_, currency| currency[:iso_numeric] == num }
        new(code) if code
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
        if object.is_a?(self)
          object
        else
          object && new(object)
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
        @table ||= synchronize { Loader.load_all }
      end

      # List the currencies imported and registered
      # @return [Array]
      #
      # @example
      #   Money::Currency.all()
      #   [#<Currency ..USD>, #<Currency ..CAD>, #<Currency ..EUR>]...
      def all
        table.keys.map do |code|
          new(code).tap do |x|
            unless x.priority
              raise "Can't call Currency.all - currency '#{code}' is missing priority"
            end
          end
        end.sort_by(&:priority)
      end

      # We need a string-based validator before creating an unbounded number of
      # symbols.
      # http://www.randomhacks.net/articles/2007/01/20/13-ways-of-looking-at-a-ruby-symbol#11
      # https://github.com/RubyMoney/money/issues/132
      #
      # @return [Set]
      def codes
        @codes ||= Set.new(table.keys)
      end

      # Register a new currency
      #
      # @param data [Hash] information about the currency
      # @option priority [Numeric] a numerical value you can use to sort/group
      #   the currency list
      # @option code [String] the international 3-letter code as defined
      #   by the ISO 4217 standard
      # @option iso_numeric [Integer] the international 3-digit code as
      #   defined by the ISO 4217 standard
      # @option name [String] the currency name
      # @option symbol [String] the currency symbol (UTF-8 encoded)
      # @option subunit [String] the name of the fractional monetary unit
      # @option subunit_to_unit [Numeric] the proportion between the unit and
      #   the subunit
      # @option separator [String] character between the whole and fraction
      #   amounts
      # @option delimiter [String] character between each thousands place
      def register(data)
        code = prepare_code(data.fetch(:code))
        synchronize do
          instances.delete(code)
          table[code] = data
        end
        @codes = nil
      end

      # Unregister a currency.
      #
      # @param [Object] data A Hash with the key `:code`, or the ISO code
      #   as a String or Symbol.
      #
      # @return [Boolean] true if the currency previously existed, false
      #   if it didn't.
      def unregister(data)
        data = data.fetch(:code) if data.is_a?(Hash)
        code = prepare_code(data)
        existed = synchronize do
          instances.delete(code)
          table.delete(code)
        end
        @codes = nil if existed
        !!existed
      end

      def each(&block)
        all.each(&block)
      end

      # Cache decimal places for subunit_to_unit values. Common ones pre-cached.
      def decimal_places_cache
        @decimal_places_cache ||= Hash.new { |h, k| h[k] = Math.log10(k).ceil }
      end

      def prepare_code(code)
        code.to_s.upcase
      end
    end

    # @!attribute [r] id
    #   @return [Symbol] The symbol used to identify the currency, usually THE
    #     lowercase +code+ attribute.
    # @!attribute [r] priority
    #   @return [Integer] A numerical value you can use to sort/group the
    #     currency list.
    # @!attribute [r] code
    #   @return [String] The international 3-letter code as defined by the ISO
    #     4217 standard.
    # @!attribute [r] iso_numeric
    #   @return [String] The international 3-numeric code as defined by the ISO
    #     4217 standard.
    # @!attribute [r] name
    #   @return [String] The currency name.
    # @!attribute [r] symbol
    #   @return [String] The currency symbol (UTF-8 encoded).
    # @!attribute [r] disambiguate_symbol
    #   @return [String] Alternative currency used if symbol is ambiguous
    # @!attribute [r] html_entity
    #   @return [String] The html entity for the currency symbol
    # @!attribute [r] subunit
    #   @return [String] The name of the fractional monetary unit.
    # @!attribute [r] subunit_to_unit
    #   @return [Integer] The proportion between the unit and the subunit
    # @!attribute [r] decimal_mark
    #   @return [String] The decimal mark, or character used to separate the
    #     whole unit from the subunit.
    # @!attribute [r] thousands_separator
    #   @return [String] The character used to separate thousands grouping of
    #     the whole unit.
    # @!attribute [r] symbol_first
    #   @return [Boolean] Should the currency symbol precede the amount, or
    #     should it come after?
    # @!attribute [r] smallest_denomination
    #   @return [Integer] Smallest amount of cash possible (in the subunit of
    #     this currency)

    ATTRS = %w(
      id
      alternate_symbols
      code
      decimal_mark
      disambiguate_symbol
      html_entity
      iso_numeric
      name
      priority
      smallest_denomination
      subunit
      subunit_to_unit
      symbol
      symbol_first
      thousands_separator
    ).map(&:to_sym).freeze

    attr_reader(*ATTRS)

    alias_method :to_sym, :id
    alias_method :to_s, :code
    alias_method :to_str, :code
    alias_method :symbol_first?, :symbol_first
    alias_method :separator, :decimal_mark
    alias_method :delimiter, :thousands_separator
    alias_method :eql?, :==

    # Create a new +Currency+ object.
    #
    # @param [String, Symbol, #to_s] id Used to look into +table+ and retrieve
    #  the applicable attributes.
    #
    # @return [Money::Currency]
    #
    # @example
    #   Money::Currency.new(:usd) #=> #<Money::Currency id: usd ...>
    def initialize(code)
      data = self.class.table[code]
      raise UnknownCurrency, "Unknown currency '#{code}'" unless data
      @id = code.to_sym
      (ATTRS - [:id]).each do |attr|
        instance_variable_set("@#{attr}", data[attr])
      end
      @alternate_symbols ||= []
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
      # <=> returns nil when one of the values is nil
      comparison = priority <=> other_currency.priority || 0
      if comparison == 0
        id <=> other_currency.id
      else
        comparison
      end
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
      if other_currency.is_a?(Currency)
        id == other_currency.id
      else
        code == other_currency.to_s.upcase
      end
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
      vals = ATTRS.map { |field| "#{field}: #{public_send(field).inspect}" }
      "#<#{self.class.name} #{vals.join(', ')}>"
    end

    # Conversion to +self+.
    #
    # @return [self]
    def to_currency
      self
    end

    # Returns currency symbol or code for currencies with no symbol.
    #
    # @return [String]
    def symbol_or_code
      symbol || code
    end

    def iso?
      !!iso_numeric
    end

    # Returns the relation between subunit and unit as a base 10 exponent.
    #
    # Note that MGA and MRO are exceptions and are rounded to 1
    # @see https://en.wikipedia.org/wiki/ISO_4217#Active_codes
    #
    # @return [Fixnum]
    def exponent
      Math.log10(subunit_to_unit).round
    end

    # The number of decimal places needed.
    #
    # @return [Integer]
    def decimal_places
      self.class.decimal_places_cache[subunit_to_unit]
    end
  end
end
