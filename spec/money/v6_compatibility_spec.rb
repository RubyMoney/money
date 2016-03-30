RSpec.describe Money, 'compatibility' do
  context 'arithmetic' do
    let(:custom_class) { Class.new(Money) { prepend Money::V6Compatibility::Arithmetic } }

    def money(*args)
      custom_class.new(*args)
    end

    def usd(*args)
      custom_class.usd(*args)
    end

    describe '#==' do
      it 'allows comparison with zero' do
        expect(usd(0)).to eq 0
        expect(usd(0)).to eq 0.0
        expect(usd(0)).to eq BigDecimal.new(0)
        expect(usd(1)).to_not eq 0
      end

      it 'raises error for non-zero numerics' do
        expect { usd(1_00) == 1 }.to raise_error ArgumentError
        expect { usd(1_00) == -2.0 }.to raise_error ArgumentError
        expect { usd(1_00) == Float::INFINITY }.to raise_error ArgumentError
      end
    end

    describe '#<=>' do
      it "returns nill when comparing with an object that doesn't inherit from Money" do
        expect(usd(1_00) <=> 100).to be_nil
        expect(usd(1_00) <=> Object.new).to be_nil
        expect(usd(1_00) <=> Class).to be_nil
        expect(usd(1_00) <=> Kernel).to be_nil
        expect(usd(1_00) <=> /foo/).to be_nil
      end

      it 'compares with numeric 0' do
        expect(usd(1) < 0).to eq false
        expect(usd(1) > 0.0).to eq true
        expect(usd(0) >= 0.0).to eq true
      end
    end

    describe '#+' do
      it "adds Fixnum 0 to money and returns the same ammount" do
        expect(usd(10_00) + 0).to eq usd(10_00)
      end
    end

    describe '#-' do
      it "subtract Fixnum 0 to money and returns the same ammount" do
        expect(usd(10_00) - 0).to eq usd(10_00)
      end
    end

    describe '#coerce' do
      it "allows mathematical operations by coercing arguments" do
        expect(2 * usd(4)).to eq usd(8)
      end

      it "raises TypeError dividing by a Money (unless other is a Money)" do
        expect { 2 / usd(2) }.to raise_exception(TypeError)
      end

      it "raises TypeError subtracting by a Money (unless other is a Money)" do
        expect { 2 - usd(2) }.to raise_exception(TypeError)
      end

      it "raises TypeError adding by a Money (unless other is a Money)" do
        expect { 2 + usd(2) }.to raise_exception(TypeError)
      end

      it "treats multiplication as commutative" do
        expect(2 * usd(2)).to eq(usd(2) * 2)
      end

      it "doesn't work with non-numerics" do
        expect { "2" * usd(2) }.to raise_exception(TypeError)
      end

      it "correctly handles <=>" do
        expect { 2 < usd(2) }.to raise_exception(ArgumentError)
        expect { 2 > usd(2) }.to raise_exception(ArgumentError)
        expect { 2 <= usd(2) }.to raise_exception(ArgumentError)
        expect { 2 >= usd(2) }.to raise_exception(ArgumentError)
        expect(2 <=> usd(2)).to be_nil
      end

      it 'compares with numeric 0' do
        expect(0 < usd(1)).to eq true
        expect(0.0 > usd(1)).to eq false
        expect(0.0 >= usd(0)).to eq true
      end

      it "raises exceptions for all numeric types, not just Integer" do
        expect { 2.0 / usd(2) }.to raise_exception(TypeError)
        expect { Rational(2,3) / usd(2) }.to raise_exception(TypeError)
        expect { BigDecimal(2) / usd(2) }.to raise_exception(TypeError)
      end
    end
  end

  context 'currency_id' do
    let(:custom_class) do
      Class.new(Money::Currency) { prepend Money::V6Compatibility::CurrencyId }
    end
    subject { custom_class.new('USD') }
    its(:id) { should eq :usd }
    its(:to_sym) { should eq :USD }
    its(:iso_code) { should eq 'USD' }
    its(:code) { should eq '$' }
  end

  describe '#format' do
    let(:formatter) { Money::V6Compatibility::Formatter }

    context 'Locale :ja' do
      with_locale :ja

      it 'formats Japanese currency in Japanese properly' do
        money = Money.new(1000, 'JPY')
        expect(formatter.format(money)).to eq '1,000円'
        expect(formatter.format(money, symbol: false)).to eq '1,000'
      end
    end
  end
end
