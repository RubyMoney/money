# encoding: utf-8

require "spec_helper"

describe Money, "extension" do
  describe Integer do
    describe "#to_string" do
      it "converts number to money with currency" do
        expect(12343543.to_string('cny')).to eq "¥123.44"
        expect(12343543.to_string('usd')).to eq "$123.44"
        expect(12343543.to_string('twd')).to eq "NT$123.44"
      end

      it "converts number to round money with currency" do
        expect(123456789.to_string('twd', round: true)).to eq "NT$1,235"
        expect(123456789.to_string('usd', round: true)).to eq "$1,235"
        expect(123423456.to_string('cny', round: true)).to eq "¥1,234"
      end

      it "converts number to ceil money with currency" do
        expect(123456789.to_string('twd', ceil: true)).to eq "NT$1,235.00"
        expect(123456789.to_string('twd', ceil: true, no_cents: true)).to eq "NT$1,235"

        expect(123456789.to_string('usd', ceil: true)).to eq "$1,235.00"
        expect(123456789.to_string('usd', ceil: true, no_cents: true)).to eq "$1,235"

        expect(123423456.to_string('cny', ceil: true)).to eq "¥1,235.00"
        expect(123423456.to_string('cny', ceil: true, no_cents: true)).to eq "¥1,235"
      end

      it "converts number to floor money with currency" do
        expect(123456789.to_string('twd', floor: true)).to eq "NT$1,234.00"
        expect(123456789.to_string('twd', floor: true, no_cents: true)).to eq "NT$1,234"

        expect(123456789.to_string('usd', floor: true)).to eq "$1,234.00"
        expect(123456789.to_string('usd', floor: true, no_cents: true)).to eq "$1,234"

        expect(123423456.to_string('cny', floor: true)).to eq "¥1,234.00"
        expect(123423456.to_string('cny', floor: true, no_cents: true)).to eq "¥1,234"
      end
    end

    describe "#to_float" do
      it "convert money from big integer value to float value" do
        expect(123426000.to_float('cny')).to eq 1234.26
        expect(123486000.to_float('usd')).to eq 1234.86
        expect(123486000.to_float('twd')).to eq 1234.86
      end
    end

    describe "#pure_round_money" do
      it "convert money from big integer value to round integer value" do
        expect(123426000.to_float('cny').round).to eq 1234
        expect(123486000.to_float('usd').round).to eq 1235
        expect(123486000.to_float('twd').round).to eq 1235
      end
    end

    describe "#raw_floor_money" do
      it "convert money from big integer value to floor value" do
        expect(123426345.to_integer('cny', {:floor => true})).to eq 123426000
        expect(123426845.to_integer('usd', {:floor => true})).to eq 123426000
      end
    end

    describe "#raw_ceil_money" do
      it "convert money from big integer value to ceil value" do
        expect(123426345.to_integer('cny', {:ceil => true})).to eq 123427000
        expect(123426845.to_integer('usd', {:ceil => true})).to eq 123427000
      end
    end
  end

  describe Float do
    describe "#to_string" do
      it "converts number to money with currency" do
        expect(123.43543.to_string('cny')).to eq "¥123.44"
        expect(123.43543.to_string('usd')).to eq "$123.44"
        expect(123.43543.to_string('twd')).to eq "NT$123.44"
      end
    end

    describe "#to_integer" do
      it "convert money from float value to big integer value" do
        expect(0.0.to_integer('twd')).to eq 0
        expect(1.0.to_integer('twd')).to eq 100000
        expect(0.123451.to_integer('twd')).to eq 12345
        expect(0.123455.to_integer('twd')).to eq 12346

        expect(0.0.to_integer('usd')).to eq 0
        expect(1.0.to_integer('usd')).to eq 100000
        expect(0.123451.to_integer('usd')).to eq 12345
        expect(0.123455.to_integer('usd')).to eq 12346
      end

      it "converts float to rounded big integer" do
        # Surprise? Don't be. That's due to imprecision of floating-point numbers.
        # 4853.453215 will be converted to 485345321.49999994 before being rounded.
        expect(4853.453215.to_integer('twd')).to eq 485345321
        expect(4853.453214.to_integer('twd')).to eq 485345321

        expect(35433.141592655.to_integer('btc')).to eq 3543314159266
        expect(35433.141592654.to_integer('btc')).to eq 3543314159265
      end

      it "converts float to least succeeding big integer" do
        expect(35433.141592655.to_integer('btc', ceil: true)).to eq 3543314159266
        expect(35433.141592654.to_integer('btc', ceil: true)).to eq 3543314159266
      end

      it "converts float to greatest preceding big integer" do
        expect(35433.141592655.to_integer('btc', floor: true)).to eq 3543314159265
        expect(35433.141592654.to_integer('btc', floor: true)).to eq 3543314159265
      end
    end

    describe "#round_by_currency" do
      it "rounds number to the last digit of subunit" do
        expect(3.141592653589793238462643.round_by_currency('btc')).to eq 3.14159265
        expect(3.141592653589793238462643.round_by_currency('twd')).to eq 3.14159
      end
    end
  end
end
