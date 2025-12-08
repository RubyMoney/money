# frozen_string_literal: true

class Money
  module LocaleBackend
    class NotSupported < StandardError; end
    class Unknown < ArgumentError; end
  end
end
