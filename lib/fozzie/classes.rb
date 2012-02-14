require 'statsd'

module Fozzie
  module Classes

    class AbstractFozzie < Statsd

      attr_reader :prefix, :configuration

      def initialize
        @namespace = Fozzie.c.data_prefix
        super Fozzie.c.host, Fozzie.c.port

        self
      end

      def time_to_do(stat, sample_rate=1, &block); time_for(stat, sample_rate, &block); end
      def time_for(stat, sample_rate=1, &block)
        stat = stat.flatten.join('.') if stat.kind_of?(Array)
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

      def deploy(app = nil); deployed(app); end
      def deployed(app = nil)
        event :deploy, app
      end

      def increment_on(stat, perf, sample_rate=1)
        key = "#{stat}.%s" % (perf ? "success" : "fail")
        increment(key, sample_rate)
        perf
      end

      private

      def event(type, app = nil)
        stat = "event.#{type.to_s}"
        stat << ".#{app}" unless app.nil?
        timing stat, Time.now.usec
      end

      def send_to_socket(message)
        begin
          ip = Fozzie.c.ip_from_host
          raise RuntimeError, "Could not locate IP" unless ip

          self.class.logger.debug {"Statsd: #{message}"} if self.class.logger
          socket.send(message, 0, ip, Fozzie.c.port)
        rescue SocketError, RuntimeError => exc
          self.class.logger.debug {"Statsd Failure: #{exc.message}"} if self.class.logger
          nil
        end
      end

    end

    def self.included(klass)
      Fozzie.c.namespaces.each do |klas|
        # set a constant
        Kernel.const_set(klas, AbstractFozzie.new) unless const_defined?(klas)
      end
    end

  end

end