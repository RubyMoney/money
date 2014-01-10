# encoding: utf-8

require "spec_helper"

describe Money do
  describe "::deprecate" do
    it "should send a deprecation message with caller" do
      error_message = "Deprecated method triggered here"

      Money.should_receive(:warn).with do |message|
        message.should =~ /DEPRECATION WARNING: #{error_message} \(called from:.*:\d+\)/
      end

      Money.deprecate(error_message)
    end

    context "when silenced" do
      it "should not warn" do
        Money.should_not_receive(:warn)

        while_silenced { Money.deprecate("anything") }
      end
    end
  end

  describe "core extensions" do
    it "does not print deprecations when silenced" do
      while_silenced do
        expect_no_deprecation_for { "$1.00".to_money }
        expect_no_deprecation_for { "USD".to_currency }
        expect_no_deprecation_for { 1.to_money }
        expect_no_deprecation_for { :USD.to_currency }
      end
    end

    def expect_no_deprecation_for(&block)
      Money.should_not_receive(:warn)
      yield
    end
  end

  def while_silenced(&block)
    begin
      old_setting = Money.silence_core_extensions_deprecations
      Money.silence_core_extensions_deprecations = true
      yield
    ensure
      Money.silence_core_extensions_deprecations = old_setting
    end
  end
end
