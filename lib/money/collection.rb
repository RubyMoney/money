class Money
  class Collection
    include Enumerable

    # @parma array [#to_a] collection of Money objects
    def initialize(array = nil)
      @collection = array.to_a
    end

    # Sums up Money objects in collection.
    # @param target_currency [Currency, String, Symbol] - currency of the returning money object.
    # @return [Money] sum of Money collection.
    def sum(target_currency = nil)
      if @collection.empty?
        return Money.new(0, target_currency)
      end

      moneys_by_currency = @collection.group_by{|money|
        money.currency
      }.values

      sum = self.class.sum_basic(moneys_by_currency.map{|moneys| self.class.sum_basic(moneys)})
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
      self
    end

    def concat(other_ary)
      @collection.concat(other_ary)
      self
    end

    private

    # Sums up Money objects using built-in :+ method.
    # @param moneys [Enumerable<Money>] list of Moneys.
    # @return [Money] sum of Money collection.
    def self.sum_basic(moneys)
      moneys.reduce{|total, money| total + money }
    end
  end
end
