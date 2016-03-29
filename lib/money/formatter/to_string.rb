class Money
  class Formatter
    class ToString < self
      def format(*)
        self.class.decimal_str(money).sub('.', separator)
      end
    end
  end
end
