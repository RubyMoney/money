RSpec.shared_examples 'instance with custom bank' do |operation, value|
  let(:custom_bank) { Money::Bank::VariableExchange.new }
  let(:instance) { Money.new(1, :usd, custom_bank) }

  subject { value ? instance.send(operation, value) : instance.send(operation) }

  it "returns custom bank from new instance" do
    new_money_instances = Array(subject).select { |el| el.is_a?(Money) }

    new_money_instances.each do |money_instance|
      expect(money_instance.bank).to eq(custom_bank)
    end
  end
end
