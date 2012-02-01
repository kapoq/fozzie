require 'spec_helper'
require 'action_controller'

describe Fozzie::Rails::Middleware do

  before :each do
    ActionController::RoutingError = Class.new(StandardError) unless defined?(ActionController::RoutingError)
  end

  subject do
    RailsApp = Class.new do
      def call(env)
        env
      end
    end unless defined?(RailsApp)
    Rails = RailsApp unless defined?(Rails)
    Fozzie::Rails::Middleware.new RailsApp.new
  end

  describe "subject" do
    it "returns env on call for testing" do
      subject.call({}).should == {}
    end
  end

  describe "rails 2" do

    before :each do
      RailsApp.stubs(:version).returns("2.3.1")
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

  describe "rails 3" do

    before :each do
      RailsApp.stubs(:version).returns("3.1.1")
      @app, @routing = Class.new, Class.new
      @app.stubs(:routes).returns(@routing)
      RailsApp.stubs(:application).returns(@app)
    end

    it "#generate_key" do
      s = '/somewhere/railsy'
      fake_env = { 'PATH_INFO' => s }
      @routing.expects(:recognize_path).with(s).returns({:controller => 'somewhere', :action => 'railsy'})
      subject.generate_key(fake_env).should == 'somewhere.railsy.render'
    end

    it "returns nil on error" do
      s = '/somewhere/railsy'
      fake_env = { 'PATH_INFO' => s }
      @routing.expects(:recognize_path).with(s).raises(ArgumentError)
      subject.generate_key(fake_env).should == nil
    end
    
    it "returns nil on routing error" do
      s = '/somewhere/railsy'
      fake_env = { 'PATH_INFO' => s }
      @routing.expects(:recognize_path).with(s).raises(ActionController::RoutingError)
      S.expects(:increment).with('routing.error')
      subject.generate_key(fake_env).should == nil
    end

  end

end