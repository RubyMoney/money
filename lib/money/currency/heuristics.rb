# encoding: utf-8

class Money
  class Currency
    module Heuristics

      # An robust and efficient algorithm for finding currencies in
      # text. Using several algorithms it can find symbols, iso codes and
      # even names of currencies.
      # Although not recommendable, it can also attempt to find the given
      # currency in an entire sentence
      #
      # Returns: Array (matched results)
      def analyze(str)
        Analyzer.new(str, SearchTree.cache[self]).process
      end

      class SearchTree
        class << self
          def cache
            @cache ||= Hash.new { |h, k| h[k] = new(k) }
          end
        end

        attr_reader :currency_class

        def initialize(currency_class)
          @currency_class = currency_class
        end

        def table
          currency_class.table
        end

        def by_symbol
          @by_symbol ||= table.each_with_object({}) do |(_, c), r|
            symbol = (c[:symbol]||"").downcase
            symbol.chomp!('.')
            (r[symbol] ||= []) << c

            (c[:alternate_symbols]||[]).each do |ac|
              ac = ac.downcase
              ac.chomp!('.')
              (r[ac] ||= []) << c
            end
          end
        end

        def by_code
          @by_code ||= table.each_with_object({}) do |(k, c), r|
            (r[k.downcase] ||= []) << c
          end
        end

        def by_name
          @by_name ||= table.each_with_object({}) do |(_, c), r|
            name_parts = c[:name].unaccent.downcase.split
            name_parts.each {|part| part.chomp!('.')}

            # construct one branch per word
            root = r
            while name_part = name_parts.shift
              root = (root[name_part] ||= {})
            end

            # the leaf is a currency
            (root[:value] ||= []) << c
          end
        end
      end

      class Analyzer
        attr_reader :search_tree, :words
        attr_accessor :str, :currencies

        def initialize(str, search_tree)
          @str = (str || '').dup
          @search_tree = search_tree
        end

        def process
          format
          return [] if str.empty?

          @currencies = []
          search_by_symbol
          search_by_code
          search_by_name

          currencies.map { |x| x[:code] }.tap(&:uniq!).tap(&:sort!)
        end

        def format
          str.gsub!(/[\r\n\t]/,'')
          str.gsub!(/[0-9][\.,:0-9]*[0-9]/,'')
          str.gsub!(/[0-9]/, '')
          str.downcase!
          @words = str.unaccent.split
          @words.each {|word| word.chomp!('.'); word.chomp!(',') }
        end

        def search_by_symbol
          words.each do |word|
            if found = search_tree.by_symbol[word]
              currencies.concat(found)
            end
          end
        end

        def search_by_code
          words.each do |word|
            if found = search_tree.by_code[word]
              currencies.concat(found)
            end
          end
        end

        def search_by_name
          # remember, the search tree by name is a construct of branches and leaf!
          # We need to try every combination of words within the sentence, so we
          # end up with a x^2 equation, which should be fine as most names are either
          # one or two words, and this is multiplied with the words of given sentence

          search_words = words.dup

          while search_words.length > 0
            root = search_tree.by_name

            search_words.each do |word|
              if root = root[word]
                if root[:value]
                  currencies.concat(root[:value])
                end
              else
                break
              end
            end

            search_words.delete_at(0)
          end
        end
      end
    end
  end
end

