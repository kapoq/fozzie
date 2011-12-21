require 'statsd'

module Fozzie
  module Classes

    class AbstractFozzie < Statsd::Client
      attr_reader :prefix

      def initialize(host, port, prefix = nil)
        @prefix = prefix
        super host, port
      end

      def time_for(data, &block)
        tick = Time.now.usec
        block.call
        tock = Time.now.usec
        timing(data, (tock - tick))
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

      private

      def event(type)
        timing "event.#{type.to_s}", Time.now.usec
      end

      # Overload the send_stats method to automicatially prefix the data bucket string
      def send_stats(data, sample_rate = 1)
        super "#{@prefix}#{data}", sample_rate
      end

    end

    NAMESPACES = %w{Stats S}

    def self.included(klass)
      host, port, prefix = Fozzie.c.host, Fozzie.c.port, Fozzie.c.data_prefix
      NAMESPACES.each do |klas|
        # set a constant
        Kernel.const_set(klas, AbstractFozzie.new(host, port, prefix)) unless const_defined?(klas)
      end
    end

  end

end