require 'spec_helper'
require 'fozzie/interface'

describe Fozzie::Dsl do

  subject { Fozzie::Dsl.instance }

  it_behaves_like "interface"

  it "acts an a singleton" do
    Fozzie.c.namespaces.each do |k|
      Kernel.const_get(k).should eq Fozzie::Dsl.instance
    end
  end

end