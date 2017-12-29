require 'spec_helper'
require 'money/collection'

RSpec.describe Money::Collection do
  # Adds up array of Money one by one and returns the sum.
  def normal_sum(array)
    array.reduce{|total, money| total + money }
  end

  before :all do
    foo = {
      :iso_code        => "FOO",
      :subunit_to_unit => 100,
    }
    Money::Currency.register(foo)

    Money.add_rate("FOO", "USD", 0.5)
    Money.add_rate("USD", "FOO", 2)
  end

  after :all do
    Money::Currency.unregister("FOO")
  end

  describe '#sum' do
    it 'sums with no element' do
      c = Money::Collection.new
      expect(c.sum).to eq(Money.zero)
    end

    it 'sums with single element' do
      c = Money::Collection.new
      c << Money.new(10,:usd)
      expect(c.sum).to eq(Money.new(10,:usd))
    end

    it 'sums same currency' do
      ary = [
        Money.new(10,:usd),
        Money.new(20,:usd),
        Money.new(30,:usd),
      ]

      c = Money::Collection.new(ary)

      expect(c.sum).to eq(Money.new(60,:usd))
    end

    it 'sums different currencies' do
      ary = [
        Money.new(100,:usd),
        Money.new(10,:foo),
      ]

      c = Money::Collection.new(ary)

      expect(c.sum).to eq(normal_sum(ary))
    end

    it 'sums correctly, avoiding rounding down error' do
      ary = [
        Money.new(10,:usd),
        Money.new(1,:foo),
        Money.new(1,:foo),
      ]

      c = Money::Collection.new(ary)

      expect(c.sum).to eq(Money.new(11,:usd))
    end

    it 'sums correctly, avoiding rounding twice if possible' do
      ary = [
        Money.new(10,:usd),
        Money.new(1,:foo),
      ]

      c = Money::Collection.new(ary)

      expect(c.sum(:foo)).to eq(Money.new(21,:foo))
    end

    it 'returns sum in the specified currency' do
      ary = [
        Money.new(10,:usd),
        Money.new(2,:foo),
      ]

      c = Money::Collection.new(ary)

      expect(c.sum('foo')).to eq(Money.new(22,:foo))
      expect(c.sum('usd')).to eq(Money.new(11,:usd))
    end

    it 'sums large number of Money' do
      10.times do
        # force first bunch to be FOO, the a bunch of USD,
        # so there won't be currency conversion error even for native sum method
        ary = 1000.times.map do
          Money.new(Random.rand(100000), :foo)
        end
        ary.concat(
          1000.times.map do
            Money.new(Random.rand(100000), :usd)
          end
        )

        c = Money::Collection.new(ary)
        expect(c.sum('foo')).to eq(normal_sum(ary))
      end
    end
  end

  describe '#min' do
    it 'returns accurate smallest Money object' do
      ary = [
        Money.new(30,:foo),
        Money.new(1,:usd),
        Money.new(3,:foo),
      ]

      c = Money::Collection.new(ary)
      expect(c.min).to eq(Money.new(1,:usd))
    end

    it 'returns smallest Money objects (from many items)' do
      ary = 1000.times.map do
        Money.new(Random.rand(100000) + 10, :foo)
      end
      c = Money::Collection.new(ary)
      min = Money.new(1, :usd)
      c << min
      expect(c.min).to eq(min)
    end
  end

  describe '#max' do
    it 'returns accurate biggest Money object' do
      ary = [
        Money.new(30,:foo),
        Money.new(1,:usd),
        Money.new(3,:foo),
      ]

      c = Money::Collection.new(ary)
      expect(c.max).to eq(Money.new(30,:foo))
    end

    it 'returns biggest Money objects (from many items)' do
      ary = 1000.times.map do
        Money.new(Random.rand(100000), :foo)
      end
      c = Money::Collection.new(ary)
      max = Money.new(100001, :usd)
      c << max
      expect(c.max).to eq(max)
    end
  end

  describe '#concat' do
    it 'concats Money objects to collection' do
      ary = [
        Money.new(10,:usd),
        Money.new(2,:foo),
      ]

      c = Money::Collection.new
      c.concat ary

      expect(c.size).to eq(2)
      expect(c.sum('foo')).to eq(Money.new(22,:foo))
    end

    it 'concats Money objects to collection multiple times' do
      ary = [
        Money.new(10,:usd),
        Money.new(2,:foo),
      ]

      c = Money::Collection.new
      c.concat ary
      c.concat ary

      expect(c.size).to eq(4)
      expect(c.sum('foo')).to eq(Money.new(44,:foo))
    end
  end

  describe '#<<' do
    it 'concats Money object to collection multiple times' do
      c = Money::Collection.new
      c << Money.new(10,:usd)
      c << Money.new(10,:foo)
      c << Money.new(10,:usd)

      expect(c.sum).to eq(Money.new(25,:usd))
    end
  end

  describe 'no side effect' do
    it 'does not change original array that is passed in the initialize method' do
      m1 = Money.new(10,:usd)
      ary = [m1]

      c = Money::Collection.new(ary)
      c << Money.new(1,:usd)

      expect(ary.size).to eq(1)
      expect(ary[0]).to eq(m1)
    end
  end
end