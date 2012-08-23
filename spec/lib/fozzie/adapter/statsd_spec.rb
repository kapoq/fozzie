require 'spec_helper'
require 'fozzie/adapter/statsd'

module Fozzie::Adapter
  describe Statsd do

    it_behaves_like "fozzie adapter"

    it "downcases any stat value" do
      subject.should_receive(:send_to_socket).with {|bin| bin.match /\.foo/ }

      subject.register("FOO", 1, 'g', 1)
    end

    describe "#format_bucket" do
      it "accepts arrays" do
        subject.format_bucket([:foo, '2']).should match /foo.2$/
        subject.format_bucket([:foo, '2']).should match /foo.2$/
        subject.format_bucket(%w{foo bar}).should match /foo.bar$/
      end

      it "converts any values to strings for stat value, ignoring nil" do
        subject.socket.should_receive(:send).with {|bin| bin.match /\.foo.1._.bar/ }

        subject.register([:foo, 1, nil, "@", "BAR"], 1, 'g', 1)
      end

      it "replaces invalid chracters" do
        subject.format_bucket([:foo, ':']).should match /foo.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/
        subject.format_bucket([:foo, '@']).should match /foo.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/
        subject.format_bucket('foo.bar.|').should match /foo.bar.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/
      end
    end

    describe "#format_value" do
      it "defaults type to gauge when type is not mapped" do
        subject.format_value(1, :foo, 1).should eq '1|g'
      end

      it "converts basic values to string" do
        subject.format_value(1, :count, 1).should eq '1|c'
      end
    end

    it "ensures block is called on socket error" do
      subject.socket.stub(:send) { raise SocketError }

      proc { subject.register('data.bin', 1, 'g', 1) { sleep 0.01 } }.should_not raise_error
      proc { subject.register('data.bin', 1, 'g', 1) { sleep 0.01 } }.should_not raise_error
    end

    it "raises Timeout on slow lookup" do
      Fozzie.c.timeout = 0.01
      subject.socket.stub(:send).with(any_args) { sleep 0.4 }

      subject.register('data.bin', 1, :gauge, 1).should eq false
    end

  end
end