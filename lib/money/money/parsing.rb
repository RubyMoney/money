#encoding: utf-8

class Money
  module Parsing
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
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
      def parse(input, currency = nil)
        i = input.to_s.strip

        # raise Money::Currency.table.collect{|c| c[1][:symbol]}.inspect

        # Check the first character for a currency symbol, alternatively get it
        # from the stated currency string
        c = if Money.assume_from_symbol && i =~ /^(\$|€|£)/
          case i
          when /^$/ then "USD"
          when /^€/ then "EUR"
          when /^£/ then "GBP"
          end
        else
          i[/[A-Z]{2,3}/]
        end

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
        new(cents, currency)
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
      def from_string(value, currency = Money.default_currency)
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
      def from_fixnum(value, currency = Money.default_currency)
        currency = Money::Currency.wrap(currency)
        amount   = value * currency.subunit_to_unit
        new(amount, currency)
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
      def from_float(value, currency = Money.default_currency)
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
      def from_bigdecimal(value, currency = Money.default_currency)
        currency = Money::Currency.wrap(currency)
        amount   = value * currency.subunit_to_unit
        new(amount.round, currency)
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
      def from_numeric(value, currency = Money.default_currency)
        case value
        when Fixnum
          from_fixnum(value, currency)
        when Numeric
          from_bigdecimal(BigDecimal.new(value.to_s), currency)
        else
          raise ArgumentError, "`value' should be a Numeric object"
        end
      end

      # Takes a number string and attempts to massage out the number.
      #
      # @param [String] input The string containing a potential number.
      #
      # @return [Integer]
      #
      def extract_cents(input, currency = Money.default_currency)
        # remove anything that's not a number, potential thousands_separator, or minus sign
        num = input.gsub(/[^\d.,'-]/, '')

        # set a boolean flag for if the number is negative or not
        negative = num =~ /^-|-$/ ? true : false

        # decimal mark character
        decimal_char = currency.decimal_mark

        # if negative, remove the minus sign from the number
        # if it's not negative, the hyphen makes the value invalid
        if negative
          num = num.sub(/^-|-$/, '')
        end

        raise ArgumentError, "Invalid currency amount (hyphen)" if num.include?('-')

        #if the number ends with punctuation, just throw it out.  If it means decimal,
        #it won't hurt anything.  If it means a literal period or comma, this will
        #save it from being mis-interpreted as a decimal.
        num.chop! if num.match(/[\.|,]$/)

          # gather all decimal_marks within the result number
          used_decimal_marks = num.scan(/[^\d]/)

          # determine the number of unique decimal_marks within the number
          #
          # e.g.
          # $1,234,567.89 would return 2 (, and .)
          # $125,00 would return 1
          # $199 would return 0
          # $1 234,567.89 would raise an error (decimal_marks are space, comma, and period)
          case used_decimal_marks.uniq.length
            # no decimal_mark or thousands_separator; major (dollars) is the number, and minor (cents) is 0
          when 0 then major, minor = num, 0

            # two decimal_marks, so we know the last item in this array is the
            # major/minor thousands_separator and the rest are decimal_marks
          when 2
            decimal_mark, thousands_separator = used_decimal_marks.uniq
            # remove all decimal_marks, split on the thousands_separator
            major, minor = num.gsub(decimal_mark, '').split(thousands_separator)
            min = 0 unless min
          when 1
            # we can't determine if the comma or period is supposed to be a decimal_mark or a thousands_separator
            # e.g.
            # 1,00 - comma is a thousands_separator
            # 1.000 - period is a thousands_separator
            # 1,000 - comma is a decimal_mark
            # 1,000,000 - comma is a decimal_mark
            # 10000,00 - comma is a thousands_separator
            # 1000,000 - comma is a thousands_separator

            # assign first decimal_mark for reusability
            decimal_mark = used_decimal_marks.first

            # When we have identified the decimal mark character
            if decimal_char == decimal_mark
              major, minor = num.split(decimal_char)

            else
              # decimal_mark is used as a decimal_mark when there are multiple instances, always
              if num.scan(decimal_mark).length > 1 # multiple matches; treat as decimal_mark
                major, minor = num.gsub(decimal_mark, ''), 0
              else
                # ex: 1,000 - 1.0000 - 10001.000
                # split number into possible major (dollars) and minor (cents) values
                possible_major, possible_minor = num.split(decimal_mark)
                possible_major ||= "0"
                possible_minor ||= "00"

                # if the minor (cents) length isn't 3, assign major/minor from the possibles
                # e.g.
                #   1,00 => 1.00
                #   1.0000 => 1.00
                #   1.2 => 1.20
                if possible_minor.length != 3 # thousands_separator
                  major, minor = possible_major, possible_minor
                else
                  # minor length is three
                  # let's try to figure out intent of the thousands_separator

                  # the major length is greater than three, which means
                  # the comma or period is used as a thousands_separator
                  # e.g.
                  #   1000,000
                  #   100000,000
                  if possible_major.length > 3
                    major, minor = possible_major, possible_minor
                  else
                    # number is in format ###{sep}### or ##{sep}### or #{sep}###
                    # handle as , is sep, . is thousands_separator
                    if decimal_mark == '.'
                      major, minor = possible_major, possible_minor
                    else
                      major, minor = "#{possible_major}#{possible_minor}", 0
                    end
                  end
                end
              end
            end
          else
            # TODO: ParseError
            raise ArgumentError, "Invalid currency amount"
          end

        # build the string based on major/minor since decimal_mark/thousands_separator have been removed
        # avoiding floating point arithmetic here to ensure accuracy
        cents = (major.to_i * currency.subunit_to_unit)
        # Because of an bug in JRuby, we can't just call #floor
        minor = minor.to_s
        minor = if minor.size < currency.decimal_places
                  (minor + ("0" * currency.decimal_places))[0,currency.decimal_places].to_i
                elsif minor.size > currency.decimal_places
                  if minor[currency.decimal_places,1].to_i >= 5
                    minor[0,currency.decimal_places].to_i+1
                  else
                    minor[0,currency.decimal_places].to_i
                  end
                else
                  minor.to_i
                end
        cents += minor

        # if negative, multiply by -1; otherwise, return positive cents
        negative ? cents * -1 : cents
      end
    end
  end
end
