require "spec_helper"

describe "Money deprecations" do

  describe Money::VariableExchangeBank do
    it "should be deprecated" do
      Money.should_receive(:deprecate)
      Money::VariableExchangeBank.new.should_not be_nil
    end

    it "should extend Money::Bank::VariableExchange" do
      Money::VariableExchangeBank.new.should be_kind_of Money::Bank::VariableExchange
    end
  end

end
