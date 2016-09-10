# encoding: utf-8
class Money
  module Utils
    # Returns installments of a money with residue dissolved in firt installments.
    #
    # @param [Integer] number of installments
    #
    # @return [Array<Money,Money>]
    #
    # @example
    #   Money.new(101).installments(3) #=> [#<Money @fractional:34>, #<Money @fractional:34>, #<Money @fractional:33>]
    def installments(number)
      installment, residual = self.divmod(number)

      installments = number.times.map { installment }
      residues     = residual.fractional.times.map { self.class.new(1, currency) }

      installments.zip(residues).map do |installment, residue|
        installment + (residue || self.class.new(0, currency))
      end
    end
  end
end
