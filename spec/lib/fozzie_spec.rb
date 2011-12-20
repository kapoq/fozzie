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
      kl.should respond_to(:update_counter)
    end
  end
  
  it "acts an a singleton" do
    Fozzie::Classes::NAMESPACES.each do |k|
      kl1, kl2 = Kernel.const_get(k), Kernel.const_get(k)
      kl1.should == kl2
    end
  end
  
  it "assigns prefix when passed" do
    Fozzie::AbstractFozzie.new(1,2, 'a').prefix.should == 'a'
  end

end