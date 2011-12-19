require 'spec_helper'
require 'core_ext/hash'

describe Hash do

  it { should respond_to(:symbolize_keys) }
  it { should respond_to(:symbolize_keys!) }

  it "manipulates keys correctly" do
    {
      '1' => 1,
      '2' => 2,
      '3' => 3
    }.symbolize_keys.should == {
      :"1" => 1,
      :"2" => 2,
      :"3" => 3
    }
  end

  it "returns copy when bang not provided" do
    hsh = { '1' => 1, '2' => 2, '3' => 3 }
    hsh.symbolize_keys
    hsh.should == { '1' => 1, '2' => 2, '3' => 3 }
  end

  it "replaces self when bang provided" do
    hsh = { '1' => 1, '2' => 2, '3' => 3 }
    hsh.symbolize_keys!
    hsh.should == { :"1" => 1, :"2" => 2, :"3" => 3 }
  end

end