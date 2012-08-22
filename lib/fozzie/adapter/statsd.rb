require 'socket'

module Fozzie
  module Adapter

    class Statsd

      RESERVED_CHARS_REGEX = /[\:\|\@\s]/
      DELIMETER = '.'

      # Send the statistic to the server
      #
      # Creates the Statsd key from the given values, and sends to socket (depending on sample rate)
      #
      def register(stat, delta, type, sample_rate)
        stat = [stat].flatten.compact.collect(&:to_s).join(DELIMETER).downcase
        stat = stat.gsub('::', DELIMETER).gsub(RESERVED_CHARS_REGEX, '_')

        k =  [Fozzie.c.data_prefix, stat].compact.join(DELIMETER)
        k << ":"
        k << [delta, type].join('|')
        k << '@%s' % sample_rate.to_s if sample_rate < 1

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
            res = socket.send(message, 0, Fozzie.c.host, Fozzie.c.port)
            Fozzie.logger.debug {"Statsd sent: #{res}"} if Fozzie.logger
            (res.to_i == message.length)
          }
        rescue => exc
          Fozzie.logger.debug {"Statsd Failure: #{exc.message}\n#{exc.backtrace}"} if Fozzie.logger
          false
        end
      end

      # The Socket we want to use to send data
      def socket
        @socket ||= ::UDPSocket.new
      end

    end

  end
end