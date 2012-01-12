require 'statsd'

module Fozzie
  module Classes

    class AbstractFozzie < Statsd
      attr_reader :prefix

      def initialize(host, port, prefix = nil)
        @namespace = prefix unless prefix.nil?
        super host, port
      end

      def time_to_do(stat, sample_rate=1, &block); time_for(stat, sample_rate, &block); end
      def time_for(stat, sample_rate=1, &block)
        time(stat, sample_rate, &block)
      end

      def committed; commit; end
      def commit
        event :commit
      end

      def build; built; end
      def built
        event :build
      end

      def deploy; deployed; end
      def deployed
        event :deploy
      end

      def increment_on(stat, perf, sample_rate=1)
        key = "#{stat}.%s" % (perf ? "success" : "fail")
        increment(key, sample_rate)
        perf
      end

      private

      def event(type)
        timing "event.#{type.to_s}", Time.now.usec
      end

      def send_to_socket(message)
        begin
          super(message)
        rescue SocketError => exc
          nil
        end
      end

    end

    NAMESPACES = %w{Stats S Statistics Warehouse}

    def self.included(klass)
      host, port, prefix = Fozzie.c.host, Fozzie.c.port, Fozzie.c.data_prefix
      NAMESPACES.each do |klas|
        # set a constant
        Kernel.const_set(klas, AbstractFozzie.new(host, port, prefix)) unless const_defined?(klas)
      end
    end

  end

end