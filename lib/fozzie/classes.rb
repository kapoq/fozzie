require 'statsd'
require 'singleton'

module Fozzie
  module Classes

    class AbstractFozzie < Statsd::Client
      include Singleton

      private

      def new(host, port)
        super Fozzie.c.host, Fozzie.c.port
      end

    end

    NAMESPACES = %w{Stats S}

    def self.included(klass)
      NAMESPACES.each do |klas|
        # set a constant
        Kernel.const_set(klas, AbstractFozzie.instance) unless const_defined?(klas)
      end
    end

  end

end