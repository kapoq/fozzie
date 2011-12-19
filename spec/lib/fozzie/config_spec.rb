require 'spec_helper'

describe Fozzie::Config do
  
  subject do
    F = Class.new { extend Fozzie::Config } unless defined?(F)
    F
  end
  
  it { should respond_to(:configure) }
  it { should respond_to(:config) }
  it { should respond_to(:c) }
  
  it "allows dynamic assignment" do
    { 
      :host    => 'somewhere.local', 
      :port    => 99, 
      :via     => :udp, 
      :timeout => 1
    }.each do |field, val|
      F.configure {|c| c.send("#{field}=", val) }
      F.c.send(field).should == val
    end
  end
  
end