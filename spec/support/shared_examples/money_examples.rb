# frozen_string_literal: true

RSpec.shared_examples "instance with custom bank" do |operation, value|
  subject { evaluated_value ? instance.send(operation, evaluated_value) : instance.send(operation) }

  let(:custom_bank) { Money::Bank::VariableExchange.new }
  let(:instance) { Money.new(1, :usd, custom_bank) }
  let(:evaluated_value) { value.respond_to?(:call) ? value.call : value }

  it "returns custom bank from new instance" do
    new_money_instances = Array(subject).select { |el| el.is_a?(Money) }

    new_money_instances.each do |money_instance|
      expect(money_instance.bank).to eq(custom_bank)
    end
  end
end
