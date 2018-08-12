class Money
  module LocaleBackend
    class NotSupported < StandardError; end
    class Unknown < ArgumentError; end
  end
end
