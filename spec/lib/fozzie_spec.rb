require 'spec_helper'

describe Fozzie do

  it { should respond_to(:c) }
  it { should respond_to(:config) }
  it { should respond_to(:configure) }

  it "allows dynamic assignment" do
    {
      :host    => 'somewhere.local',
      :port    => 99
    }.each do |field, val|
      Fozzie.configure {|c| c.send("#{field}=", val) }
      Fozzie.c.send(field).should == val
    end
  end

  it "has configuration" do
    Fozzie.config.should be_kind_of(Fozzie::Configuration)
    Fozzie.c.should be_kind_of(Fozzie::Configuration)
  end

  it "creates new classes for statistics gathering" do
    Fozzie.c.namespaces.each do |k|
      Kernel.const_defined?(k).should == true
    end
  end

  it "acts like its inherited parent" do
    Fozzie.c.namespaces.each do |k|
      kl = Kernel.const_get(k)
      kl.should respond_to(:increment)
      kl.should respond_to(:decrement)
      kl.should respond_to(:timing)
      kl.should respond_to(:count)
      kl.should respond_to(:time)
    end
  end

end