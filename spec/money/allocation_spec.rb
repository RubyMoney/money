# encoding: utf-8

describe Money::Allocation do
  describe 'given number as argument' do
    it 'raises an error when invalid argument is given' do
      expect { described_class.generate(100, 0) }.to raise_error(ArgumentError)
      expect { described_class.generate(100, -1) }.to raise_error(ArgumentError)
    end

    context 'whole amounts' do
      it 'returns the amount when 1 is given' do
        expect(described_class.generate(100, 1)).to eq([100])
      end

      it 'splits the amount into equal parts' do
        expect(described_class.generate(100, 2)).to eq([50, 50])
        expect(described_class.generate(100, 4)).to eq([25, 25, 25, 25])
        expect(described_class.generate(100, 5)).to eq([20, 20, 20, 20, 20])
      end

      it 'does not loose pennies' do
        expect(described_class.generate(5, 2)).to eq([3, 2])
        expect(described_class.generate(2, 3)).to eq([1, 1, 0])
        expect(described_class.generate(100, 3)).to eq([34, 33, 33])
        expect(described_class.generate(100, 6)).to eq([17, 17, 17, 17, 16, 16])
      end
    end

    context 'fractional amounts' do
      it 'returns the amount when 1 is given' do
        expect(described_class.generate(BigDecimal(100), 1, false)).to eq([BigDecimal(100)])
      end

      it 'splits the amount into equal parts' do
        expect(described_class.generate(BigDecimal(100), 2, false)).to eq([50, 50])
        expect(described_class.generate(BigDecimal(100), 4, false)).to eq([25, 25, 25, 25])
        expect(described_class.generate(BigDecimal(100), 5, false)).to eq([20, 20, 20, 20, 20])
      end

      it 'splits the amount into equal fractions' do
        expect(described_class.generate(BigDecimal(5), 2, false)).to eq([2.5, 2.5])
        expect(described_class.generate(BigDecimal(5), 4, false)).to eq([1.25, 1.25, 1.25, 1.25])
      end

      it 'handles splits into repeating decimals' do
        amount = BigDecimal(100)
        parts = described_class.generate(amount, 3, false)

        # Rounding due to inconsistent BigDecimal size in ruby compared to jruby. In reality the
        # first 2 elements will look like the last one with a '5' at the end, compensating for a
        # missing fraction
        expect(parts.map { |x| x.round(10) }).to eq([
          BigDecimal('33.3333333333'),
          BigDecimal('33.3333333333'),
          BigDecimal('33.3333333333')
        ])
        expect(parts.inject(0, :+)).to eq(amount)
      end
    end
  end

  describe 'given array as argument' do
    it 'raises an error when invalid argument is given' do
      expect { described_class.generate(100, []) }.to raise_error(ArgumentError)
    end

    context 'whole amounts' do
      it 'returns the amount when array contains only one element' do
        expect(described_class.generate(100, [1])).to eq([100])
        expect(described_class.generate(100, [5])).to eq([100])
      end

      it 'splits the amount into whole parts respecting the order' do
        expect(described_class.generate(100, [1, 1])).to eq([50, 50])
        expect(described_class.generate(100, [1, 1, 2])).to eq([25, 25, 50])
        expect(described_class.generate(100, [7, 3])).to eq([70, 30])
      end

      it 'accepts floats as arguments' do
        expect(described_class.generate(100, [1.0, 1.0])).to eq([50, 50])
        expect(described_class.generate(100, [0.1, 0.1, 0.2])).to eq([25, 25, 50])
        expect(described_class.generate(100, [0.07, 0.03])).to eq([70, 30])
        expect(described_class.generate(10, [0.1, 0.2, 0.1])).to eq([3, 5, 2])
      end

      it 'does not loose pennies' do
        expect(described_class.generate(10, [1, 1, 2])).to eq([3, 2, 5])
        expect(described_class.generate(100, [1, 1, 1])).to eq([34, 33, 33])
      end
    end

    context 'fractional amounts' do
      it 'returns the amount when array contains only one element' do
        expect(described_class.generate(BigDecimal(100), [1], false)).to eq([100])
        expect(described_class.generate(BigDecimal(100), [5], false)).to eq([100])
      end

      it 'splits the amount into whole parts respecting the order' do
        expect(described_class.generate(BigDecimal(100), [1, 1], false)).to eq([50, 50])
        expect(described_class.generate(BigDecimal(100), [1, 1, 2], false)).to eq([25, 25, 50])
        expect(described_class.generate(BigDecimal(100), [7, 3], false)).to eq([70, 30])
      end

      it 'splits the amount proportionally to the given parts' do
        expect(described_class.generate(BigDecimal(10), [1, 1, 2], false)).to eq([2.5, 2.5, 5])
        expect(described_class.generate(BigDecimal(7), [1, 1], false)).to eq([3.5, 3.5])
      end

      it 'keeps the class of the splits the same as given amount' do
        # Note that whole_amount is false but result is whole values
        expect(described_class.generate(10, [1, 1, 2], false)).to eq([3, 2, 5])
      end

      it 'handles splits into repeating decimals' do
        amount = BigDecimal(100)
        parts = described_class.generate(amount, [1, 1, 1], false)

        # Rounding due to inconsistent BigDecimal size in ruby compared to jruby. In reality the
        # first 2 elements will look like the last one with a '5' at the end, compensating for a
        # missing fraction
        expect(parts.map { |x| x.round(10) }).to eq([
          BigDecimal('33.3333333333'),
          BigDecimal('33.3333333333'),
          BigDecimal('33.3333333333')
        ])
        expect(parts.inject(0, :+)).to eq(amount)
      end
    end
  end
end
