# encoding: utf-8

require "json"
require "money/currency/loader"
require "money/currency/heuristics"

class Money

  # Represents a specific currency unit.
  #
  # @see https://en.wikipedia.org/wiki/Currency
  # @see http://iso4217.net/
  class Currency
    include Comparable
    extend Enumerable
    extend Money::Currency::Heuristics

    # Keeping cached instances in sync between threads
    @@mutex = Mutex.new
    @@instances = {}

    # Thrown when a Currency has been registered without all the attributes
    # which are required for the current action.
    class MissingAttributeError < StandardError
      def initialize(method, currency, attribute)
        super(
          "Can't call Currency.#{method} - currency '#{currency}' is missing "\
          "the attribute '#{attribute}'"
        )
      end
    end

    # Thrown when an unknown currency is requested.
    class UnknownCurrency < ArgumentError; end

    class << self
      def new(id)
        id = id.to_s.downcase
        unless stringified_keys.include?(id)
          raise UnknownCurrency, "Unknown currency '#{id}'"
        end

        _instances[id] || @@mutex.synchronize { _instances[id] ||= super }
      end

      def _instances
        @@instances
      end

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
        new(id)
      rescue UnknownCurrency
        nil
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
      #   Money::Currency.find_by_iso_numeric(51) #=> #<Money::Currency id: amd ...>
      #   Money::Currency.find_by_iso_numeric('001') #=> nil
      def find_by_iso_numeric(num)
        num = num.to_s.rjust(3, '0')
        return if num.empty?
        id, _ = self.table.find { |key, currency| currency[:iso_numeric] == num }
        new(id)
      rescue UnknownCurrency
        nil
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
      # https://www.answers.com/topic/monetary-unit
      # == fractional monetary unit, subunit
      # A monetary unit that is valued at a fraction (usually one hundredth) of the basic monetary unit
      # https://www.answers.com/topic/fractional-monetary-unit-subunit
      #
      # See https://en.wikipedia.org/wiki/List_of_circulating_currencies and
      # http://search.cpan.org/~tnguyen/Locale-Currency-Format-1.28/Format.pm
      def table
        @table ||= Loader.load_currencies
      end

      # List the currencies imported and registered
      # @return [Array]
      #
      # @example
      #   Money::Currency.all()
      #   [#<Currency ..USD>, 'CAD', 'EUR']...
      def all
        table.keys.map do |curr|
          c = Currency.new(curr)
          if c.priority.nil?
            raise MissingAttributeError.new(:all, c.id, :priority)
          end
          c
        end.sort_by(&:priority)
      end

      # We need a string-based validator before creating an unbounded number of
      # symbols.
      # http://www.randomhacks.net/articles/2007/01/20/13-ways-of-looking-at-a-ruby-symbol#11
      # https://github.com/RubyMoney/money/issues/132
      #
      # @return [Set]
      def stringified_keys
        @stringified_keys ||= stringify_keys
      end

      # Register a new currency
      #
      # @param curr [Hash] information about the currency
      # @option priority [Numeric] a numerical value you can use to sort/group
      #   the currency list
      # @option iso_code [String] the international 3-letter code as defined
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
      def register(curr)
        key = curr.fetch(:iso_code).downcase.to_sym
        @@mutex.synchronize { _instances.delete(key.to_s) }
        @table[key] = curr
        @stringified_keys = nil
      end

      # Inherit a new currency from existing one
      #
      # @param parent_iso_code [String] the international 3-letter code as defined
      # @param curr [Hash] See {register} method for hash structure
      def inherit(parent_iso_code, curr)
        parent_iso_code = parent_iso_code.downcase.to_sym
        curr = @table.fetch(parent_iso_code, {}).merge(curr)
        register(curr)
      end

      # Unregister a currency.
      #
      # @param [Object] curr A Hash with the key `:iso_code`, or the ISO code
      #   as a String or Symbol.
      #
      # @return [Boolean] true if the currency previously existed, false
      #   if it didn't.
      def unregister(curr)
        if curr.is_a?(Hash)
          key = curr.fetch(:iso_code).downcase.to_sym
        else
          key = curr.downcase.to_sym
        end
        existed = @table.delete(key)
        @stringified_keys = nil if existed
        existed ? true : false
      end

      def each
        all.each { |c| yield(c) }
      end

      def reset!
        @@instances = {}
        @table = Loader.load_currencies
      end

      private

      def stringify_keys
        table.keys.each_with_object(Set.new) { |k, set| set.add(k.to_s.downcase) }
      end
    end

    # @!attribute [r] id
    #   @return [Symbol] The symbol used to identify the currency, usually THE
    #     lowercase +iso_code+ attribute.
    # @!attribute [r] priority
    #   @return [Integer] A numerical value you can use to sort/group the
    #     currency list.
    # @!attribute [r] iso_code
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

    attr_reader :id, :priority, :iso_code, :iso_numeric, :name, :symbol,
      :disambiguate_symbol, :html_entity, :subunit, :subunit_to_unit, :decimal_mark,
      :thousands_separator, :symbol_first, :smallest_denomination, :format

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
    def initialize(id)
      @id = id.to_sym
      initialize_data!
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
      comparison = self.priority <=> other_currency.priority || 0

      if comparison == 0
        self.id <=> other_currency.id
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
      self.equal?(other_currency) || compare_ids(other_currency)
    end

    def compare_ids(other_currency)
      other_currency_id = if other_currency.is_a?(Currency)
                            other_currency.id.to_s.downcase
                          else
                            other_currency.to_s.downcase
                          end
      self.id.to_s.downcase == other_currency_id
    end
    private :compare_ids

    # Returns a Integer hash value based on the +id+ attribute in order to use
    # functions like & (intersection), group_by, etc.
    #
    # @return [Integer]
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
      "#<#{self.class.name} id: #{id}, priority: #{priority}, symbol_first: #{symbol_first}, thousands_separator: #{thousands_separator}, html_entity: #{html_entity}, decimal_mark: #{decimal_mark}, name: #{name}, symbol: #{symbol}, subunit_to_unit: #{subunit_to_unit}, exponent: #{exponent}, iso_code: #{iso_code}, iso_numeric: #{iso_numeric}, subunit: #{subunit}, smallest_denomination: #{smallest_denomination}, format: #{format}>"
    end

    # Returns a string representation corresponding to the upcase +id+
    # attribute.
    #
    # --
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

    # Returns a string representation corresponding to the upcase +id+
    # attribute. Useful in cases where only implicit conversions are made.
    #
    # @return [String]
    #
    # @example
    #   Money::Currency.new(:usd).to_str #=> "USD"
    #   Money::Currency.new(:eur).to_str #=> "EUR"
    def to_str
      id.to_s.upcase
    end

    # Returns a symbol representation corresponding to the upcase +id+
    # attribute.
    #
    # @return [Symbol]
    #
    # @example
    #   Money::Currency.new(:usd).to_sym #=> :USD
    #   Money::Currency.new(:eur).to_sym #=> :EUR
    def to_sym
      id.to_s.upcase.to_sym
    end

    # Conversion to +self+.
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

    # Returns if a code currency is ISO.
    #
    # @return [Boolean]
    #
    # @example
    #   Money::Currency.new(:usd).iso?
    #
    def iso?
      iso_numeric && iso_numeric != ''
    end

    # Returns the relation between subunit and unit as a base 10 exponent.
    #
    # Note that MGA and MRU are exceptions and are rounded to 1
    # @see https://en.wikipedia.org/wiki/ISO_4217#Active_codes
    #
    # @return [Integer]
    def exponent
      Math.log10(subunit_to_unit).round
    end
    alias decimal_places exponent

    private

    def initialize_data!
      data = self.class.table[@id]
      @alternate_symbols     = data[:alternate_symbols]
      @decimal_mark          = data[:decimal_mark]
      @disambiguate_symbol   = data[:disambiguate_symbol]
      @html_entity           = data[:html_entity]
      @iso_code              = data[:iso_code]
      @iso_numeric           = data[:iso_numeric]
      @name                  = data[:name]
      @priority              = data[:priority]
      @smallest_denomination = data[:smallest_denomination]
      @subunit               = data[:subunit]
      @subunit_to_unit       = data[:subunit_to_unit]
      @symbol                = data[:symbol]
      @symbol_first          = data[:symbol_first]
      @thousands_separator   = data[:thousands_separator]
      @format                = data[:format]
    end
  end
end
