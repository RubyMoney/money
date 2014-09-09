# encoding: utf-8

require "json"
require "money/currency/loader"
require "money/currency/heuristics"

class Money

  # Represents a specific currency unit.
  #
  # @see http://en.wikipedia.org/wiki/Currency
  # @see http://iso4217.net/
  class Currency
    include Comparable
    extend Money::Currency::Loader
    extend Money::Currency::Heuristics

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
      #   Money::Currency.find_by_iso_numeric('001') #=> nil
      def find_by_iso_numeric(num)
        num = num.to_s
        id, _ = self.table.find{|key, currency| currency[:iso_numeric] == num}
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

      # List the currencies imported and registered
      # @return [Array]
      #
      # @example
      #   Money::Currency.iso_codes()
      #   [#<Currency ..USD>, 'CAD', 'EUR']...
      def all
        table.keys.map {|curr| Currency.new(curr)}.sort_by(&:priority)
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

      def unregister(curr)
        key = curr[:iso_code].downcase.to_sym
        @table.delete(key)
        @stringified_keys = stringify_keys
      end

      private

      def stringify_keys
        table.keys.each_with_object(Set.new) { |k, set| set.add(k.to_s.downcase) }
      end
    end

    # @attr_reader [Symbol] id The symbol used to identify the currency,
    # usually the lowercase +iso_code+ attribute.
    # @attr_reader [Integer] priority A numerical value you can use to
    # sort/group the currency list.
    # @attr_reader [String] iso_code The international 3-letter code as defined
    # by the ISO 4217 standard.
    # @attr_reader [String] iso_numeric The international 3-numeric code as
    # defined by the ISO 4217 standard.
    # @attr_reader [String] name The currency name.
    # @attr_reader [String] symbol The currency symbol (UTF-8 encoded).
    # @attr_reader [String] html_entity The html entity for the currency symbol
    # @attr_reader [String] subunit The name of the fractional monetary unit.
    # @attr_reader [Integer] subunit_to_unit The proportion between the unit
    # and the subunit
    # @attr_reader [String] decimal_mark The decimal mark, or character used to
    # separate the whole unit from the subunit.
    # @attr_reader [String] The character used to separate thousands grouping
    # of the whole unit.
    # @attr_reader [Boolean] symbol_first Should the currency symbol precede
    # the amount, or should it come after?
    # @attr_reader [Integer] smallest_denomination Smallest amount of cash 
    # possible (in the subunit of this currency)

    attr_reader :id, :priority, :iso_code, :iso_numeric, :name, :symbol,
      :html_entity, :subunit, :subunit_to_unit, :decimal_mark,
      :thousands_separator, :symbol_first, :smallest_denomination

    alias_method :separator, :decimal_mark
    alias_method :delimiter, :thousands_separator

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

      if self.class.stringified_keys.include?(id)
        @id = id.to_sym
        data = self.class.table[@id]
        @priority = data[:priority]
        @iso_code = data[:iso_code]
        @name = data[:name]
        @symbol = data[:symbol]
        @alternate_symbols = data[:alternate_symbols]
        @subunit = data[:subunit]
        @subunit_to_unit = data[:subunit_to_unit]
        @symbol_first = data[:symbol_first]
        @html_entity = data[:html_entity]
        @decimal_mark = data[:decimal_mark]
        @thousands_separator = data[:thousands_separator]
        @iso_numeric = data[:iso_numeric]
        @smallest_denomination = data[:smallest_denomination]
      else
        raise UnknownCurrency, "Unknown currency '#{id}'"
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
      "#<#{self.class.name} id: #{id}, priority: #{priority}, symbol_first: #{symbol_first}, thousands_separator: #{thousands_separator}, html_entity: #{html_entity}, decimal_mark: #{decimal_mark}, name: #{name}, symbol: #{symbol}, subunit_to_unit: #{subunit_to_unit}, exponent: #{exponent}, iso_code: #{iso_code}, iso_numeric: #{iso_numeric}, subunit: #{subunit}, smallest_denomination: #{smallest_denomination}>"
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
      @decimal_places_cache ||= {1 => 0, 10 => 1, 100 => 2, 1000 => 3}
    end

    # The number of decimal places needed.
    #
    # @return [Integer]
    def decimal_places
      cache[subunit_to_unit] ||= calculate_decimal_places(subunit_to_unit)
    end

    def cache
      self.class.decimal_places_cache
    end
    private :cache

    # If we need to figure out how many decimal places we need we
    # use repeated integer division.
    def calculate_decimal_places(num)
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
