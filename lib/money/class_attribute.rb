class Money
  module ClassAttribute
    # Simple version of ActiveSupport's class_attribute. Defines only class-methods,
    # does not support any options.
    #
    # :api: private
    def class_attribute(*attrs)
      attrs.each do |name|
        # singleton_class.class_eval do
        #   define_method(name) { nil }
        #   define_method("#{name}=") do |val|
        #     remove_method(name)
        #     define_method(name) { val }
        #   end
        # end
        define_singleton_method(name) { nil }
        define_singleton_method("#{name}=") do |val|
          singleton_class.class_eval do
            remove_method(name) if instance_methods(false).include?(name)
            define_method(name) { val }
          end
        end
      end
    end
  end
end