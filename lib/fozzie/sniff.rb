require 'core_ext/module/monitor'
require 'facets'

module Fozzie
  module Sniff

    def self.included(klass)
      return if klass.include?(ClassMethods)

      klass.class_eval { extend ClassMethods }
    end

    module ClassMethods

      def _monitor
        @_monitor_flag = true
      end

      def _monitor_meth(target, &blk)
        return if @_monitor_flag.nil? || !@_monitor_flag

        @_monitor_flag, feature, bin = false, :monitor, [self.name, target.to_s]
        aliased_target, punctuation  = target.to_s.sub(/([?!=])$/, ''), $1

        with    = "#{aliased_target}_with_#{feature}#{punctuation}"
        without = "#{aliased_target}_without_#{feature}#{punctuation}"

        blk.call(with, without, feature, bin)
      end

      def method_added(target)
        _monitor_meth(target) do |with, without, feature, bin|
          define_method(with) do |*args|
            S.time_for(bin) { args.empty? ? self.send(without) : self.send(without, *args) }
          end
          self.alias_method_chain(target, feature)
        end
      end

      def singleton_method_added(target)
        _monitor_meth(target) do |with, without, feature, bin|
          define_singleton_method(with) do |*args|
            S.time_for(bin) { args.empty? ? send(without) : send(without, *args) }
          end
          self.singleton_class.class_eval { alias_method_chain target, feature }
        end
      end

    end

  end
end