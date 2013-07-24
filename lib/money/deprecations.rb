class Money
  # Displays a deprecation warning message.
  #
  # @param [String] message The message to display.
  #
  # @return [nil]
  def self.deprecate(message)
    warn "DEPRECATION WARNING: #{message}"
  end
end
