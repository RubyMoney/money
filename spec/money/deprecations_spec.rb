# encoding: utf-8

require "spec_helper"

describe Money do
  describe "#deprecate" do
    let(:error_message) { "Deprecated method triggered here" }

    it "should send a deprecation message with caller" do
      Money.should_receive(:warn).with do |message|
        message.should =~ /DEPRECATION WARNING: #{error_message} \(called from:.*:\d+\)/
      end

      Money.deprecate(error_message)
    end
  end
end
