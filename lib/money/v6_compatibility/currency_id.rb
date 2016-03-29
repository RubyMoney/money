class Money
  module V6Compatibility
    module_function

    def currency_id
      Currency.prepend(CurrencyId)
      Currency.instances.clear
    end

    module CurrencyId
      def initialize(*)
        super
        @id = @code.downcase.to_sym
      end

      def to_sym
        @code.to_sym
      end

      def code
        symbol || @code
      end

      def iso_code
        @code
      end
    end
  end
end