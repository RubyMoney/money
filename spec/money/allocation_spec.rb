# encoding: utf-8

describe Money::Allocation do
  describe 'given number as argument' do
    it 'raises an error when invalid argument is given' do
      expect { described_class.new(100, 0) }.to raise_error(ArgumentError)
      expect { described_class.new(100, -1) }.to raise_error(ArgumentError)
    end

    context 'whole amounts' do
      it 'returns the amount when 1 is given' do
        expect(described_class.new(100, 1).generate).to eq([100])
      end

      it 'splits the amount into equal parts' do
        expect(described_class.new(100, 2).generate).to eq([50, 50])
        expect(described_class.new(100, 4).generate).to eq([25, 25, 25, 25])
        expect(described_class.new(100, 5).generate).to eq([20, 20, 20, 20, 20])
      end

      it 'does not loose pennies' do
        expect(described_class.new(5, 2).generate).to eq([3, 2])
        expect(described_class.new(2, 3).generate).to eq([1, 1, 0])
        expect(described_class.new(100, 3).generate).to eq([34, 33, 33])
        expect(described_class.new(100, 6).generate).to eq([17, 17, 17, 17, 16, 16])
      end
    end

    context 'fractional amounts' do
      it 'returns the amount when 1 is given' do
        expect(described_class.new(BigDecimal(100), 1, false).generate).to eq([BigDecimal(100)])
      end

      it 'splits the amount into equal parts' do
        expect(described_class.new(BigDecimal(100), 2, false).generate).to eq([50, 50])
        expect(described_class.new(BigDecimal(100), 4, false).generate).to eq([25, 25, 25, 25])
        expect(described_class.new(BigDecimal(100), 5, false).generate).to eq([20, 20, 20, 20, 20])
      end

      it 'splits the amount into equal fractions' do
        expect(described_class.new(BigDecimal(5), 2, false).generate).to eq([2.5, 2.5])
        expect(described_class.new(BigDecimal(5), 4, false).generate).to eq([1.25, 1.25, 1.25, 1.25])
      end

      it 'handles splits into repeating decimals' do
        amount = BigDecimal(100)
        parts = described_class.new(amount, 3, false).generate

        expect(parts).to eq([
          BigDecimal('33.3333333333333333335'),
          BigDecimal('33.3333333333333333335'),
          BigDecimal('33.333333333333333333')
        ])
        expect(parts.inject(0, :+)).to eq(amount)
      end
    end
  end

  describe 'given array as argument' do
    it 'raises an error when invalid argument is given' do
      expect { described_class.new(100, []) }.to raise_error(ArgumentError)
    end

    context 'whole amounts' do
      it 'returns the amount when array contains only one element' do
        expect(described_class.new(100, [1]).generate).to eq([100])
        expect(described_class.new(100, [5]).generate).to eq([100])
      end

      it 'splits the amount into whole parts respecting the order' do
        expect(described_class.new(100, [1, 1]).generate).to eq([50, 50])
        expect(described_class.new(100, [1, 1, 2]).generate).to eq([25, 25, 50])
        expect(described_class.new(100, [7, 3]).generate).to eq([70, 30])
      end

      it 'accepts floats as arguments' do
        expect(described_class.new(100, [1.0, 1.0]).generate).to eq([50, 50])
        expect(described_class.new(100, [0.1, 0.1, 0.2]).generate).to eq([25, 25, 50])
        expect(described_class.new(100, [0.07, 0.03]).generate).to eq([70, 30])
      end

      it 'does not loose pennies' do
        expect(described_class.new(10, [1, 1, 2]).generate).to eq([3, 2, 5])
        expect(described_class.new(100, [1, 1, 1]).generate).to eq([34, 33, 33])
      end
    end

    context 'fractional amounts' do
      it 'returns the amount when array contains only one element' do
        expect(described_class.new(BigDecimal(100), [1], false).generate).to eq([100])
        expect(described_class.new(BigDecimal(100), [5], false).generate).to eq([100])
      end

      it 'splits the amount into whole parts respecting the order' do
        expect(described_class.new(BigDecimal(100), [1, 1], false).generate).to eq([50, 50])
        expect(described_class.new(BigDecimal(100), [1, 1, 2], false).generate).to eq([25, 25, 50])
        expect(described_class.new(BigDecimal(100), [7, 3], false).generate).to eq([70, 30])
      end

      it 'splits the amount proportionally to the given parts' do
        expect(described_class.new(BigDecimal(10), [1, 1, 2], false).generate).to eq([2.5, 2.5, 5])
        expect(described_class.new(BigDecimal(7), [1, 1], false).generate).to eq([3.5, 3.5])
      end

      it 'handles splits into repeating decimals' do
        amount = BigDecimal(100)
        parts = described_class.new(amount, [1, 1, 1], false).generate

        expect(parts).to eq([
          BigDecimal('33.3333333333333333335'),
          BigDecimal('33.3333333333333333335'),
          BigDecimal('33.333333333333333333')
        ])
        expect(parts.inject(0, :+)).to eq(amount)
      end
    end
  end
end
