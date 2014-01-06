require "bigdecimal"
require "bigdecimal/util"
require "i18n"
require "money/currency"
require "money/money"
require "money/core_extensions/numeric"
require "money/core_extensions/string"
require "money/core_extensions/symbol"
require "money/deprecations"

class Money
  class << self
    attr_accessor :silence_core_extensions_deprecations
  end

  self.silence_core_extensions_deprecations = false
end
