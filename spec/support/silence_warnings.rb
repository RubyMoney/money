# frozen_string_literal: true

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

class Money::Bank::VariableExchange
  include Money::Warning
end
