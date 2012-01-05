require 'spec_helper'
require 'fozzie/classes'

describe Fozzie do

  it { should respond_to(:c) }
  it { should respond_to(:config) }

  it "has configuration" do
    Fozzie.config.should be_kind_of(Fozzie::Configuration)
    Fozzie.c.should be_kind_of(Fozzie::Configuration)
  end

  it "creates new classes for statistics gathering" do
    Fozzie::Classes::NAMESPACES.each do |k|
      Kernel.const_defined?(k).should == true
    end
  end

  it "acts like its inherited parent" do
    Fozzie::Classes::NAMESPACES.each do |k|
      kl = Kernel.const_get(k)
      kl.should respond_to(:increment)
      kl.should respond_to(:decrement)
      kl.should respond_to(:timing)
      kl.should respond_to(:count)
      kl.should respond_to(:time)
    end
  end

  it "acts an a singleton" do
    Fozzie::Classes::NAMESPACES.each do |k|
      kl1, kl2 = Kernel.const_get(k), Kernel.const_get(k)
      kl1.should == kl2
    end
  end

  it "assigns namespace when passed" do
    Fozzie::AbstractFozzie.new(1,2, 'a').namespace.should == 'a'
  end

  it "times a given block" do
    Stats.expects(:timing).with() {|b, val, timing| b == 'data.bin' && (1000..1200).include?(val) }.twice
    Stats.time_for('data.bin') { sleep 1 }
    Stats.time_to_do('data.bin') { sleep 1 }
  end

  it "registers a commit" do
    Stats.expects(:timing).with('event.commit', anything).twice
    Stats.commit
    Stats.committed
  end

  it "registers a build" do
    Stats.expects(:timing).with('event.build', anything).twice
    Stats.build
    Stats.built
  end

  it "registers a deploy" do
    Stats.expects(:timing).with('event.deploy', anything).twice
    Stats.deploy
    Stats.deployed
  end
  
  it "ensures block is called on socket error" do
    Stats.stubs(:time).raises(SocketError)
    proc { Stats.time_for('data.bin') { sleep 1 } }.should_not raise_error
    proc { Stats.time_to_do('data.bin') { sleep 1 } }.should_not raise_error
  end
  
  it "raises exception if natural exception from block" do
    proc { Stats.time_for('data.bin') { raise ArgumentError, "testing" } }.should raise_error(ArgumentError)
  end

end