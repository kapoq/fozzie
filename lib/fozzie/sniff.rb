module Fozzie
  module Sniff

    # Trigger the sniff
    def self.enable!
      Object.class_eval do

        def self.singleton_method_added(name)
          return if Fozzie::Sniff.registered?(self, name) || !Fozzie.c.want_to_monitor?(self)
          Fozzie::Sniff.sniff_class_method(self, name)
        end

        def self.method_added(name)
          return if Fozzie::Sniff.registered?(self, name) || !Fozzie.c.want_to_monitor?(self)
          Fozzie::Sniff.sniff_instance_method(self, name)
        end

      end
    end

    # Registry of sniff methods by class
    def self.registry
      @registry ||= {}
    end

    # Is the given klass and method already registered?
    def self.registered?(klass, method)
      method = method_name(method)

      (registry[klass.to_s.to_sym] and registry[klass.to_s.to_sym].include?(method))
    end

    # Register a given klass and method for sniff
    def self.register(klass, method)
      method = method_name(method)

      registry[klass.to_s.to_sym] ||= []
      registry[klass.to_s.to_sym].push(method)
    end

    # Set sniff on a class method
    def self.sniff_class_method(klass, method)
      n, o = :"#{method}_k_orig", method.to_sym

      register(klass, method)

      klass.class_eval(%q{class << self; alias_method :%s, :%s end} % [n, o])
      klass.class_eval do
        define_singleton_method o do
          b = [self.name, 'class', o].collect {|s| s.to_s.gsub('::', '.').gsub('_', '.') }
          S.time_for(b) { class_eval(n) }
        end
      end
    end

    # Set sniff on an instance method
    def self.sniff_instance_method(klass, method)
      n, o = :"#{method}_orig", method.to_sym

      register(klass, method)

      klass.class_eval do |k|
        alias_method n, o
        define_method o do
          b = [self.class.name, 'instance', o].collect {|s| s.to_s.gsub('::', '.').gsub('_', '.') }
          S.time_for(b) { send(n) }
        end
      end
    end

    # Enable sniff on a single klass when included
    def self.included(klass)
      klass.instance_methods(false).each  {|m| monitor_instance_method(klass, m) }
      klass.methods(false).each           {|m| monitor_class_method(klass, m) }
    end

    private

    def self.method_name(method)
      method.to_s.gsub('_k', '').gsub('_orig', '').to_sym
    end

  end
end