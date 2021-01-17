$LOAD_PATH.unshift File.dirname(__FILE__)
require "rspec"
require "money"

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

I18n.enforce_available_locales = false

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end

def reset_i18n
  I18n.backend = I18n::Backend::Simple.new
end

RSpec.shared_context "with infinite precision", :default_infinite_precision_true do
  before do
    Money.default_infinite_precision = true
  end

  after do
    Money.default_infinite_precision = false
  end
end

class Money
  module Warning
    def warn(message); end
  end
end

class Money
  include Warning
  extend Warning
end

class Money::LocaleBackend::Base
  include Money::Warning
end

class Money::FormattingRules
  include Money::Warning
end
