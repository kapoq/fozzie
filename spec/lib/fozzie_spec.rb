require 'spec_helper'
require 'logger'

describe Fozzie do

  it "allows dynamic assignment" do
    { :host => 'somewhere.local', :port => 99 }.each do |field, val|
      Fozzie.configure {|c| c.send("#{field}=", val) }
      Fozzie.c.send(field).should == val
    end
  end

  it "allows assignment of logger" do
    logger = Logger.new STDOUT
    Fozzie.logger = logger
    Fozzie.logger.should be logger
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

end