require 'spec_helper'
require 'fozzie/adapter/statsd'

module Fozzie::Adapter
  describe Statsd do

    it { should respond_to(:register) }

    it "downcases any stat value" do
      subject.expects(:send_to_socket)
        .with {|bin| bin.match /\.foo/ }

      subject.register("FOO", 1, 'g', 1)
    end

    it "replaces invalid stat value chars" do
      subject.expects(:send_to_socket)
        .with {|bin| bin.match /\.foo_/ }
        .times(4)

      subject.register("FOO:", 1, 'g', 1)
      subject.register("FOO@", 1, 'g', 1)
      subject.register("FOO|", 1, 'g', 1)
      subject.register(["FOO|"], 1, 'g', 1)
    end

    it "converts any values to strings for stat value, ignoring nil" do
      subject.socket.expects(:send)
        .with {|bin| bin.match /\.foo.1._.bar/ }

      subject.register([:foo, 1, nil, "@", "BAR"], 1, 'g', 1)
    end

    it "ensures block is called on socket error" do
      subject.socket.stubs(:send).raises(SocketError)
      proc { subject.register('data.bin', 1, 'g', 1) { sleep 0.01 } }.should_not raise_error
      proc { subject.register('data.bin', 1, 'g', 1) { sleep 0.01 } }.should_not raise_error
    end

    it "raises Timeout on slow lookup" do
      Fozzie.c.timeout = 0.01
      subject.socket.stubs(:send).with(any_parameters) { sleep 0.4 }
      subject.register('data.bin', 1, 'g', 1).should eq false
    end

  end
end