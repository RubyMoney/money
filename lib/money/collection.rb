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
        sum = self.class.sum_basic(
          @group_by_currency.values.map{|moneys|
            self.class.sum_single_currency(moneys)
          }
        )
      end

      if target_currency.nil?
        sum
      else
        sum.exchange_to(target_currency)
      end
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
      other_ary.each do |obj|
        if @group_by_currency[obj.currency].nil?
          @group_by_currency[obj.currency] = [obj]
        else
          @group_by_currency[obj.currency] << obj
        end
      end
      self
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
