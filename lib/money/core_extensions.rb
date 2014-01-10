require "money/core_extensions/numeric"
require "money/core_extensions/string"
require "money/core_extensions/symbol"

Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use core extensions. Please start using the Monetize gem from https://github.com/RubyMoney/monetize if you are not already doing so."

Money.silence_core_extensions_deprecations = true
