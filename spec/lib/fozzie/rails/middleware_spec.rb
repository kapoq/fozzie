require 'spec_helper'
require 'action_controller'

describe Fozzie::Rails::Middleware do

  subject do
    RailsApp = Class.new do
      def call(env)
        env
      end
    end unless defined?(RailsApp)
    Fozzie::Rails::Middleware.new RailsApp.new
  end

  describe "subject" do
    it "returns env on call for testing" do
      subject.call({}).should == {}
    end
  end

  it "#generate_key" do
    s = '/somewhere/railsy'
    fake_env = { 'PATH_INFO' => s }
    ActionController::Routing::Routes.expects(:recognize_path).with(s).returns({:controller => 'somewhere', :action => 'railsy'})
    subject.generate_key(fake_env).should == 'somewhere.railsy.render'
  end
  
  it "returns nil on routing error" do
    s = '/somewhere/railsy'
    fake_env = { 'PATH_INFO' => s }
    ActionController::Routing::Routes.expects(:recognize_path).with(s).raises(ArgumentError)
    subject.generate_key(fake_env).should == nil
  end

end