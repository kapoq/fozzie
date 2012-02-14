require 'spec_helper'
require 'resolv'

describe Fozzie::Configuration do

  it "#host" do
    subject.host.should be_kind_of(String)
  end

  it "#port" do
    subject.port.should be_kind_of(Fixnum)
  end

  it "attempts to load configuration from yaml" do
    c = Fozzie::Configuration.new({:env => 'test', :config_path => 'spec/'})
    c.stubs(:origin_name).returns("")
    c.host.should == '1.1.1.1'
    c.port.should == 9876
    c.appname.should == 'fozzie'
    c.data_prefix.should == 'fozzie.test'
  end

  it "defaults env" do
    subject.env.should == 'development'
  end

  it "creates a data prefix" do
    subject.stubs(:origin_name).returns("")
    subject.data_prefix.should == 'development'
  end

  it "creates a data prefix with appname when set" do
    subject.stubs(:origin_name).returns("")
    subject.appname = 'astoria'
    subject.data_prefix.should == 'astoria.development'
  end

  it "creates a prefix with origin" do
    subject.stubs(:origin_name).returns("app.server.local")
    subject.appname = 'astoria'
    subject.data_prefix.should == 'astoria.app-server-local.development'
  end

  it "handles missing configuration namespace" do
    proc { Fozzie::Configuration.new({:env => 'blbala', :config_path => 'spec/'}) }.should_not raise_error
  end

  it "#namespaces" do
    subject.namespaces.should be_kind_of(Array)
    subject.namespaces.should include("Stats")
    subject.namespaces.should include("S")
  end

  describe "#ip_from_host" do

    it "returns host if host an ip" do
      c = Fozzie::Configuration.new({:env => 'test', :config_path => nil, :host => '127.0.0.1'})
      c.ip_from_host.should == '127.0.0.1'
    end

    it "assigns nil on miss" do
      Resolv.expects(:getaddresses).with('some.awesome.log.server').returns([]).twice

      c = Fozzie::Configuration.new({:env => 'test', :config_path => nil, :host => 'some.awesome.log.server'})
      c.ip_from_host.should == nil
      c.ip_from_host.should == nil
    end

    it "looks up ip from host" do
      c = Fozzie::Configuration.new({:env => 'test', :config_path => nil, :host => 'lonelyplanet.com'})
      c.ip_from_host.should match(/^(?:\d{1,3}\.){3}\d{1,3}$/)
    end

    it "caches the ip once it is retrieved" do
      Resolv.expects(:getaddresses).with('lonelyplanet.com').returns(["1.1.1.1"])
      c = Fozzie::Configuration.new({:env => 'test', :config_path => nil, :host => 'lonelyplanet.com'})
      c.ip_from_host.should == c.ip_from_host
    end

  end

end