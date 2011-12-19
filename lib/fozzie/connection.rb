require 'socket'
require 'ipaddr'

module Fozzie

  # TODO:: expose the supported connections in a clear way
  # Connection to the data gathering service
  class Connection

    # send a packet to the data warehouse/service
    def self.send_data(data)
      meth = "via_#{Fozzie.c.via.to_s}"
      raise RuntimeError, "#{Fozzie.c.via.to_s} currently not supported" unless self.respond_to?(meth)
      self.send(meth, data)
    end

    private

    # Send packet via tcp
    def self.via_tcp(data)
      TCPSocket.open(Fozzie.c.host, Fozzie.c.port) do |sock|
        s.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, Fozzie.c.timeout)
        sock.puts(data)
      end rescue nil
    end

    # Send packet via udp
    def self.via_udp(data)
      s = UDPSocket.new
      s.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, Fozzie.c.timeout)
      s.send(data, 0, Fozzie.c.host, Fozzie.c.port) rescue nil
    end

  end
end