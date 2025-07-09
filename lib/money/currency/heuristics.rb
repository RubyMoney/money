# frozen_string_literal: true

class Money
  class Currency
    module Heuristics
      def analyze(str)
        raise StandardError, 'Heuristics deprecated, add `gem "money-heuristics"` to Gemfile'
      end
    end
  end
end
