require 'money'

class Money
  class Collection
    include Enumerable

    # @parma array [#to_a] collection of Money objects
    def initialize(array = nil)
      @collection = array.to_a.dup
      @group_by_currency = @collection.group_by(&:currency)
    end

    # Sums up Money objects in collection.
    # @param target_currency [Currency, String, Symbol] - currency of the returning money object.
    # @return [Money] sum of Money collection.
    def sum(target_currency = nil)
      if @collection.empty?
        return Money.new(0, target_currency)
      end

      if @group_by_currency.size == 1
        sum = self.class.sum_single_currency(@collection)
      else
        sums_per_currency = @group_by_currency.values.map{|moneys|
          self.class.sum_single_currency(moneys)
        }

        # If target_currency is specified, and is in collection,
        # move it to the front so it has precedence over other currencies.
        if target_currency
          target_currency = Money::Currency.wrap(target_currency)
          if index = sums_per_currency.find_index{|money| money.currency == target_currency}
            money = sums_per_currency.delete_at(index)
            sums_per_currency.unshift money
          end
        end

        sum = self.class.sum_basic(sums_per_currency)
      end

      if target_currency.nil?
        sum
      else
        sum.exchange_to(target_currency)
      end
    end

    def max
      @group_by_currency.values.map{|moneys|
        moneys.max_by{|money| money.fractional}
      }.max
    end

    def min
      @group_by_currency.values.map{|moneys|
        moneys.min_by{|money| money.fractional}
      }.min
    end

    #### delegations

    def each
      if block_given?
        @collection.each{|x| yield(x)}
        self
      else
        @collection.each
      end
    end

    def <<(obj)
      @collection << obj
      if @group_by_currency[obj.currency].nil?
        @group_by_currency[obj.currency] = [obj]
      else
        @group_by_currency[obj.currency] << obj
      end
      self
    end

    def concat(other_ary)
      @collection.concat(other_ary)
      other_ary.group_by(&:currency).each do |currency, ary|
        if @group_by_currency[currency].nil?
          @group_by_currency[currency] = ary
        else
          @group_by_currency[currency].concat(ary)
        end
      end
      self
    end

    def size
      @collection.size
    end

    private

    # Sums up Money objects using built-in :+ method.
    # @param moneys [Enumerable<Money>] list of Moneys.
    # @return [Money] sum of Money collection.
    def self.sum_basic(moneys)
      moneys.reduce{|total, money| total + money }
    end

    # Sums up Money objects of the same currency.
    # Number of object creation is minimized.
    # @param moneys [Enumerable<Money>] list of Moneys. There is no validation so caller must ensure all Moneys belong to the same currency.
    # @return [Money] sum of Money collection.
    def self.sum_single_currency(moneys)
      total_fractional = moneys.reduce(0){|fractional, money| fractional += money.fractional }
      Money.new(total_fractional, moneys[0].currency)
    end
  end
end
