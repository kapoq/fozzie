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
    UDPSocket.any_instance.stubs(:send).raises(SocketError)
    proc { Stats.time_for('data.bin') { sleep 1 } }.should_not raise_error
    proc { Stats.time_to_do('data.bin') { sleep 1 } }.should_not raise_error
  end

  it "raises exception if natural exception from block" do
    proc { Stats.time_for('data.bin') { raise ArgumentError, "testing" } }.should raise_error(ArgumentError)
  end

  it "only calls the block once on SocketError" do
    UDPSocket.any_instance.stubs(:send).raises(SocketError)
    i = 0
    p = proc {|n| (n + 1) }
    val = Stats.time_for('data.bin') { i+= p.call(i) }
    val.should == 1
  end

  describe "#increment_on" do

    it "registers success" do
      Stats.expects(:increment).with("event.increment.success", 1)
      Stats.increment_on('event.increment', true).should == true
    end

    it "registers failure" do
      Stats.expects(:increment).with("event.increment.fail", 1)
      Stats.increment_on('event.increment', false).should == false
    end
    
    it "simply questions the passed val with if" do
      a = mock()
      a.expects(:save).returns({})
      Stats.expects(:increment).with("event.increment.success", 1)
      Stats.increment_on('event.increment', a.save).should == {}
    end
    
    it "registers fail on nil return" do
      a = mock()
      a.expects(:save).returns(nil)
      Stats.expects(:increment).with("event.increment.fail", 1)
      Stats.increment_on('event.increment', a.save).should == nil
    end

    describe "performing actions" do

      it "registers success" do
        a = mock()
        a.expects(:save).returns(true)
        Stats.expects(:increment).with("event.increment.success", 1)
        Stats.increment_on('event.increment', a.save).should == true
      end

      it "registers failure" do
        a = mock()
        a.expects(:save).returns(false)
        Stats.expects(:increment).with("event.increment.fail", 1)
        Stats.increment_on('event.increment', a.save).should == false
      end

      it "registers positive even when nested" do
        a = mock()
        a.expects(:save).returns(true)
        Stats.expects(:timing).with('event.run', any_parameters)
        Stats.expects(:increment).with("event.increment.success", 1)

        res = Stats.time_to_do "event.run" do
          Stats.increment_on('event.increment', a.save)
        end
        res.should == true
      end
      
      it "registers negative even when nested" do
        a = mock()
        a.expects(:save).returns(false)
        Stats.expects(:timing).with('event.run', any_parameters)
        Stats.expects(:increment).with("event.increment.fail", 1)

        res = Stats.time_to_do "event.run" do
          Stats.increment_on('event.increment', a.save)
        end
        res.should == false
      end
      
      it "allows passing of arrays for stat key" do
        Stats.expects(:timing).with('event.commit', any_parameters)
        Stats.time_to_do %w{event commit} do; end
      end

    end

  end

end