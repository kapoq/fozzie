require 'spec_helper'
require 'socket'

describe Fozzie::Connection do

  it { Fozzie::Connection.should respond_to(:send_data) }

  it "#send_data" do
    proc {
      Fozzie::Connection.send_data('foo.bar.baz 42 74857843')
    }.should_not raise_error
  end

  it "ignores errors on connecting" do
    Fozzie.config {|c| c.host = 'nowhere' }
    proc {
      10.times { Fozzie::Connection.send_data('%s %s %s' % ['test.bin', rand(80), Time.now.to_i]) }
    }.should_not raise_error
  end

  describe "connects via" do

    before do
      @value = 'foo.bar.baz 42 74857843'
    end

    it "tcp" do
      Fozzie.configure {|c| c.via = :tcp }
      Fozzie::Connection.expects(:via_tcp)
      Fozzie::Connection.send_data(@value)
    end
    
    it "udp" do
      Fozzie.configure {|c| c.via = :udp }
      Fozzie::Connection.expects(:via_udp)
      Fozzie::Connection.send_data(@value)
    end

  end

end