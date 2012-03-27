module Fozzie
  module Socket

    RESERVED_CHARS_REGEX = /[\:\|\@]/

    private

    # Send the statistic to the server
    def send(stat, delta, type, sample_rate)
      prefix = "%s." % Fozzie.c.data_prefix unless Fozzie.c.data_prefix.nil?
      stat   = stat.to_s.gsub('::', '.').gsub(RESERVED_CHARS_REGEX, '_')

      k = "%s%s:%s|%s" % [prefix, stat, delta, type]
      k << '|@%s' % sample_rate.to_s if sample_rate < 1

      sampled(sample_rate) { send_to_socket(k.strip) }
    end

    # If the statistic is sampled, generate a condition to check if it's good to send
    def sampled(sample_rate)
      yield unless sample_rate < 1 and rand > sample_rate
    end

    # Send data to the server via the socket
    def send_to_socket(message)
      begin
        Fozzie.logger.debug {"Statsd: #{message}"} if Fozzie.logger
        Timeout.timeout(Fozzie.c.timeout) {
          socket.send(message, 0, Fozzie.c.host, Fozzie.c.port)
          true
        }
      rescue => exc
        Fozzie.ogger.debug {"Statsd Failure: #{exc.message}\n#{exc.backtrace}"} if Fozzie.logger
        false
      end
    end

    # The Socket we want to use to send data
    def socket
      @socket ||= UDPSocket.new
    end

  end
end