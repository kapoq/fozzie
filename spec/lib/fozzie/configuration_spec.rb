require 'spec_helper'

describe Fozzie::Configuration do

  it "#host" do
    subject.host.should be_kind_of(String)
  end

  it "#port" do
    subject.port.should be_kind_of(Fixnum)
  end

  it "attempts to load configuration from yaml" do
    c = Fozzie::Configuration.new({:env => 'test', :config_path => 'spec/'})
    c.host.should == '1.1.1.1'
    c.port.should == 9876
  end

  it "defaults env" do
    subject.env.should == 'development'
  end

end