module Fozzie
  class Connection

    def self.send_data(data)
      TCPSocket.open(Fozzie.c.host, Fozzie.c.port) do |sock|
        sock.puts(data)
      end rescue nil
    end

  end
end