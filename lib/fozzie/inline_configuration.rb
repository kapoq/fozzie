module Fozzie
  module Inline
    def self.included(base)
      base.class_eval { extend ClassMethods }
    end

    module ClassMethods
      def singleton_method_added(m)
        register_method(m, self) if time_next_method_added?
      end

      def time_with_fozzie
        @time_next_method_added = true
      end
      
      def time_next_method_added?
        @time_next_method_added ||= false
      end
        
      def method_added(m)
        register_method(m, self) if time_next_method_added?
      end

      def register_method(m, obj)
        @time_next_method_added = false

        obj.alias_method_chain(m, :fozzie_logging) do |aliased_target, punctuation|
          obj.send(:define_method, "#{aliased_target}_with_fozzie_logging") do |*args|
            S.time_for(m) { obj.send(aliased_target, *args) }
          end
        end
      end

      # TODO: import from alias_method_chain
      def alias_method_chain(target, feature)
        # Strip out punctuation on predicates or bang methods since
        # e.g. target?_without_feature is not a valid method name.
        aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
        yield(aliased_target, punctuation) if block_given?

        with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"

        alias_method without_method, target
        alias_method target, with_method

        case
          when public_method_defined?(without_method)
            public target
          when protected_method_defined?(without_method)
            protected target
          when private_method_defined?(without_method)
            private target
        end
      end
    end

  end
end
