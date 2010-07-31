class Money

  def self.deprecate(message)
    warn "DEPRECATION WARNING: #{message}"
  end

end