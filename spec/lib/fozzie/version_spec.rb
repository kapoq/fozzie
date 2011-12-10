require 'spec_helper'

describe "Fozzie Version" do

  it "exists" do
    Fozzie::VERSION.should be_kind_of(String)
    Fozzie::VERSION.should match(/\d{1,3}?\.?/)
  end

end