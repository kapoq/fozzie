require 'spec_helper'
require 'fozzie/sniff'

describe Fozzie::Sniff do

  before :all do
    Fozzie.enable_sniff!
    Fozzie.c.add_monitor_class :Sn

    Sn ||= Class.new
    Sn.class_eval do
      def bar
        :bar
      end
      def self.foo
        :class_foo
      end
    end
  end

  it "times instance methods" do
    S.expects(:time_for).with(['Sn', 'instance', 'bar']).returns(:bar)
    Sn.new.bar.should eq :bar
  end

  it "times class methods" do
    S.expects(:time_for).with(['Sn', 'class', 'foo']).returns(:class_foo)
    Sn.foo.should eq :class_foo
  end

end