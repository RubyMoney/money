require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'

module Monetizable
  extend ActiveSupport::Concern

  module ClassMethods
    def monetize(field, *args)
      options = args.extract_options!

      # Stringify model field name
      subunit_name = field.to_s

      # Model currency field name
      model_currency_name = options[:model_currency] || "currency"

      # Override Model and default currency
      field_currency_name = options[:field_currency] || nil

      # Form target name for the money backed ActiveModel field:
      # if a target name is provided then use it
      # if there is a "_cents" suffix then just remove it to create the target name
      # if none of the previous is the case then use a default suffix
      if options[:target_name]
        name = options[:target_name]
      elsif subunit_name =~ /_cents$/
        name = subunit_name.sub(/_cents$/, "")
      else
        # FIXME: provide a better default
        name = subunit_name << "_money"
      end

      class_eval do
        composed_of name.to_sym,
          :class_name => "Money",
          :mapping => [[subunit_name, "cents"], [model_currency_name, "currency_as_string"]],
          :constructor => Proc.new { |cents, currency|
            Money.new(cents || 0, field_currency_name || currency ||
                      Money.default_currency)
          },
          :converter => Proc.new { |value|
            if  value.respond_to?(:to_money)
              if field_currency_name
                value.to_money(field_currency_name)
              else
                value.to_money
              end
            else
              raise(ArgumentError, "Can't convert #{value.class} to Money")
            end
          }
      end
    end
  end
end
