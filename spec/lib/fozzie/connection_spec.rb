require 'spec_helper'

describe Fozzie::Connection do

  it { Fozzie::Connection.should respond_to(:send_data) }

  it "#send_data" do
    proc { 
      Fozzie::Connection.send_data('blablabla') 
    }.should_not raise_error
  end

end