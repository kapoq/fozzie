require 'spec_helper'

describe Fozzie do

  it { should respond_to(:count) }
  it { should respond_to(:timer) }
  it { should respond_to(:sample) }
  it { should respond_to(:c) }
  it { should respond_to(:config) }
  
  it "has configuration" do
    Fozzie.config.should be_kind_of(Fozzie::Configuration)
    Fozzie.c.should be_kind_of(Fozzie::Configuration)
  end

  it "registers count" do
    Fozzie::Connection.expects(:send_data).with('test.bucket:1|c')
    Fozzie.count('test.bucket', 1)
  end

  it "registers timing" do
    Fozzie::Connection.expects(:send_data).with('test.bucket:320|ms')
    Fozzie.timer('test.bucket', 320, 'ms')
  end

  it "registers sampling" do
    Fozzie::Connection.expects(:send_data).with('test.bucket:1|c|@0.1')
    Fozzie.sample('test.bucket', 1, :count, 0.1)
  end

end