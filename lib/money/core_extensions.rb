require "money/core_extensions/numeric"
require "money/core_extensions/string"
require "money/core_extensions/symbol"

Money.deprecate "as of Money 6.1.0 you must `require 'monetize/core_extensions'` to use core extensions."

Money.silence_core_extensions_deprecations = true
