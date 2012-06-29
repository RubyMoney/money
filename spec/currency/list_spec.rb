# encoding: utf-8

require 'spec_helper'

class Money::Currency
  describe List do
    let(:klass) { Class.new }

    context 'having extended a class' do
      before { klass.extend List }

      describe '.table' do
        subject { klass.table }
        it { should_not be_empty }
      end
    end
  end
end
