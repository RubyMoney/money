# Open +Numeric+ to add new method.
class Numeric
  # Converts this numeric to a +Money+ object in the default currency.
  #
  # @param [optional, Money::Currency, String, Symbol] currency The currency to
  #  set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @example
  #   100.to_money                   #=> #<Money @cents=10000>
  #   100.37.to_money                #=> #<Money @cents=10037>
  #   require 'bigdecimal'
  #   BigDecimal.new('100').to_money #=> #<Money @cents=10000>
  def to_money(currency = Money.default_currency)
    currency = Money::Currency.new(currency) unless currency.is_a?(Money::Currency)
    amt = self * currency.subunit_to_unit
    amt = case amt.class.to_s
          when 'BigDecimal'
            amt.to_s('F')
          else
            amt.to_s
          end
    Money.new(amt.to_i, currency)
  end
end

# Open +String+ to add new methods.
class String
  # Parses the current string and converts it to a +Money+ object. Excess
  # characters will be discarded.
  #
  # @param [optional, Money::Currency, String, Symbol] currency The currency to
  #  set the resulting +Money+ object to.
  #
  # @return [Money]
  #
  # @example
  #   '100'.to_money                #=> #<Money @cents=10000>
  #   '100.37'.to_money             #=> #<Money @cents=10037>
  #   '100 USD'.to_money            #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   'USD 100'.to_money            #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   '$100 USD'.to_money           #=> #<Money @cents=10000, @currency=#<Money::Currency id: usd>>
  #   'hello 2000 world'.to_money   #=> #<Money @cents=200000 @currency=#<Money::Currency id: usd>>
  def to_money(currency = nil)
    # Get the currency.
    matches = scan /([A-Z]{2,3})/
    _currency_ = matches[0] ? matches[0][0] : nil

    # check that currency passed and embedded currency are the same, or only
    # one or the other is present.
    if currency.nil? and _currency_.nil?
      currency = Money.default_currency
    elsif currency.nil?
      currency = _currency_
    elsif _currency_.nil?
      currency = currency
    elsif currency != _currency_
      raise "mismatching currencies"
    end

    cents = calculate_cents(self)
    Money.new(cents, currency)
  end

  # Parses the current string and converts it to a +Currency+ object.
  #
  # @return [Money::Currency]
  #
  # @example
  #   "USD".to_currency #=> #<Money::Currency id: usd>
  def to_currency
    Money::Currency.new(self)
  end

  private

  # Takes a number string and attempts to massage out the number.
  #
  # @param [String] number The string containing a potential number.
  #
  # @return [Integer]
  def calculate_cents(number)
    # remove anything that's not a number, potential delimiter, or minus sign
    num = number.gsub(/[^\d|\.|,|\'|\s|\-]/, '').strip

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
      raise ArgumentError, "Invalid currency amount"
    end

    # build the string based on major/minor since separator/delimiters have been removed
    # avoiding floating point arithmetic here to ensure accuracy
    cents = (major.to_i * 100)
    # add the minor number as well. this may have any number of digits,
    # so we treat minor as a string and truncate or right-fill it with zeroes
    # until it becomes a two-digit number string, which we add to cents.
    minor = minor.to_s
    truncated_minor = minor[0..1]
    truncated_minor << "0" * (2 - truncated_minor.size) if truncated_minor.size < 2
    cents += truncated_minor.to_i
    # respect rounding rules
    if minor.size >= 3 && minor[2..2].to_i >= 5
      cents += 1
    end

    # if negative, multiply by -1; otherwise, return positive cents
    negative ? cents * -1 : cents
  end
end
