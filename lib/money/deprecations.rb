class Money
  # Displays a deprecation warning message.
  #
  # @param [String] message The message to display.
  #
  # @return [nil]
  def self.deprecate(message)
    warn "DEPRECATION WARNING: #{message}"
  end


  # Money::VariableExchangeBank is the legacy default bank
  # shipped with Money. The class has been superseded by
  # Money::Bank::VariableExchange.
  #
  # @deprecated Use Money::Bank::VariableExchange instead. 
  class VariableExchangeBank < Bank::VariableExchange # :nodoc:
    # Calls +Money#deprecate+ the super.
    def initialize(*args)
      Money.deprecate "Money::VariableExchangeBank is deprecated and will be removed in v3.2.0. Use Money::Bank::VariableExchange instead."
      super
    end
  end
end
