# encoding: utf-8
describe Money do
  let(:amount)       { 100 }
  let(:installments) { 5 }

  subject { Money.new(amount) }

  describe '#installments' do
    it "returns size's array equal number of installments" do
      expect(subject.installments(installments).size).to eq(installments)
    end

    it 'ensures total of installments is the same of amount' do
      installments_sum = subject.installments(installments).inject(:+)
      expect(installments_sum).to eq(subject)
    end

    context 'when number of installments is less than amount value' do
      let(:amount) { 3 }

      it 'returns installments with amount equal zero' do
        latest_installment = subject.installments(installments).last(2)

        latest_installment.each do |instalment|
          expect(instalment).to be_zero
        end
      end
    end

    context 'when modulus is zero' do
      it 'returns same value for all instalments' do
        expect(subject.installments(installments).uniq.size).to eq(1)
      end
    end

    context 'when modulus is not zero' do
      let(:amount)       { 101 }
      let(:installments) { 3 }

      it 'dissolves residue in first installments' do
        first_installments = subject.installments(installments).first(2)

        first_installments.each do |instalment|
          expect(instalment.fractional).to eq(34)
        end
      end
    end
  end
end
