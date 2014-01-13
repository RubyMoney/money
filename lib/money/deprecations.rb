class Money
  # Displays a deprecation warning message.
  #
  # @param [String] message The message to display.
  #
  # @return [nil]
  def self.deprecate(message)
    unless Money.silence_core_extensions_deprecations
      file, line = caller(2).first.split(':', 2)
      line = line.to_i

      warn "DEPRECATION WARNING: #{message} (called from: #{file}:#{line})"
    end
  end
end
