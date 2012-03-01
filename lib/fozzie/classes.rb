module Fozzie
  module Classes

    class AbstractFozzie

      RESERVED_CHARS_REGEX = /[\:\|\@]/

      attr_reader :prefix, :configuration

      # Sends an increment (count = 1) for the given stat to the statsd server.
      #
      # @param stat (see #count)
      # @param sample_rate (see #count)
      # @see #count
      def increment(stat, sample_rate=1)
        count(stat, 1, sample_rate)
      end

      # Sends a decrement (count = -1) for the given stat to the statsd server.
      #
      # @param stat (see #count)
      # @param sample_rate (see #count)
      # @see #count
      def decrement(stat, sample_rate=1)
        count(stat, -1, sample_rate)
      end

      # Sends an arbitrary count for the given stat to the statsd server.
      #
      # @param [String] stat stat name
      # @param [Integer] count count
      # @param [Integer] sample_rate sample rate, 1 for always
      def count(stat, count, sample_rate=1)
        send(stat, count, 'c', sample_rate)
      end

      # Sends a timing (in ms) for the given stat to the statsd server. The
      # sample_rate determines what percentage of the time this report is sent. The
      # statsd server then uses the sample_rate to correctly track the average
      # timing for the stat.
      #
      # @param stat stat name
      # @param [Integer] ms timing in milliseconds
      # @param [Integer] sample_rate sample rate, 1 for always
      def timing(stat, ms, sample_rate=1)
        send(stat, ms, 'ms', sample_rate)
      end

      # Reports execution time of the provided block using {#timing}.
      #
      # @param stat (see #timing)
      # @param sample_rate (see #timing)
      # @yield The operation to be timed
      # @see #timing
      # @example Report the time (in ms) taken to activate an account
      #   $statsd.time('account.activate') { @account.activate! }
      def time(stat, sample_rate=1)
        stat   = stat.flatten.join('.') if stat.kind_of?(Array)
        start  = Time.now
        result = yield
        timing(stat, ((Time.now - start) * 1000).round, sample_rate)
        result
      end

      def time_to_do(stat, sample_rate=1, &block)
        time_for(stat, sample_rate, &block)
      end

      def time_for(stat, sample_rate=1, &block)
        time(stat, sample_rate, &block)
      end

      def commit
        event :commit
      end
      def committed; commit; end

      def built
        event :build
      end
      def build; built; end

      def deployed(app = nil)
        event :deploy, app
      end
      def deploy(app = nil); deployed(app); end

      def increment_on(stat, perf, sample_rate=1)
        key = "#{stat}.%s" % (perf ? "success" : "fail")
        increment(key, sample_rate)
        perf
      end

      def logger
        self.class.logger
      end

      def self.logger
        @logger
      end

      private

      def event(type, app = nil)
        stat = "event.#{type.to_s}"
        stat << ".#{app}" unless app.nil?
        timing stat, Time.now.usec
      end

      def send_to_socket(message)
        return false if Fozzie.c.ip_from_host.blank?
        begin
          self.class.logger.debug {"Statsd: #{message}"} if self.class.logger
          socket.send(message, 0, Fozzie.c.ip_from_host, Fozzie.c.port)
        rescue SocketError, RuntimeError, Errno::EADDRNOTAVAIL, Timeout::Error => exc
          self.class.logger.debug {"Statsd Failure: #{exc.message}"} if self.class.logger
          nil
        end
      end

      def sampled(sample_rate)
        yield unless sample_rate < 1 and rand > sample_rate
      end

      def send(stat, delta, type, sample_rate)
        prefix = "#{Fozzie.c.data_prefix}." unless Fozzie.c.data_prefix.nil?
        stat = stat.to_s.gsub('::', '.').gsub(RESERVED_CHARS_REGEX, '_')
        sampled(sample_rate) { send_to_socket("#{prefix}#{stat}:#{delta}|#{type}#{'|@' << sample_rate.to_s if sample_rate < 1}") }
      end

      def socket
        @socket ||= UDPSocket.new
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