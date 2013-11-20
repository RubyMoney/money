class Money
  # Displays a deprecation warning message.
  #
  # @param [String] message The message to display.
  #
  # @return [nil]
  def self.deprecate(message)
    file, line = caller(2).first.split(':', 2)
    line = line.to_i

    warn "DEPRECATION WARNING: #{message} (called from: #{file}:#{line})"
  end
end
