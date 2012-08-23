require 'spec_helper'

describe Module do

  it "includes _monitor method when required" do
    Module.should respond_to(:_monitor)
  end

end