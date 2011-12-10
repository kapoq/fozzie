require 'spec_helper'

describe Fozzie::Configuration do

  it "#host" do
    subject.host.should be_kind_of(String)
  end

  it "#port" do
    subject.port.should be_kind_of(Fixnum)
  end

end