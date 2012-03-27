require 'spec_helper'
require 'action_controller'

describe Fozzie::Rails::Middleware do
  let(:path_info) { '/somewhere/railsy' }
  let(:fake_env)  { ({ 'PATH_INFO' => path_info }) }

  before :each do
    unless defined?(ActionController::RoutingError)
      ActionController::RoutingError = Class.new(StandardError)
    end
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
    let!(:version) { RailsApp.stubs(:version).returns("2.3.1") }

    it "#generate_key" do
      ActionController::Routing::Routes.expects(:recognize_path)
        .with(path_info)
        .returns({:controller => 'somewhere', :action => 'railsy'})

      subject.generate_key(fake_env).should == 'somewhere.railsy.render'
    end

    it "returns nil on routing error" do
      ActionController::Routing::Routes.expects(:recognize_path)
        .with(path_info)
        .raises(ArgumentError)

      subject.generate_key(fake_env).should == nil
    end

  end

  describe "rails 3" do
    let(:app)       { Class.new }
    let(:routing)   { Class.new }
    let!(:rails)    { RailsApp.stubs(:application).returns(app) }
    let!(:version)  { RailsApp.stubs(:version).returns("3.1.1") }
    let!(:routes)   { app.stubs(:routes).returns(routing)}

    it "#generate_key" do
      routing.expects(:recognize_path)
        .with(path_info)
        .returns({:controller => 'somewhere', :action => 'railsy'})

      subject.generate_key(fake_env).should == 'somewhere.railsy.render'
    end

    it "returns nil on error" do
      routing.expects(:recognize_path)
        .with(path_info)
        .raises(ArgumentError)

      subject.generate_key(fake_env).should == nil
    end

    it "returns nil on routing error" do
      routing.expects(:recognize_path)
        .with(path_info)
        .raises(ActionController::RoutingError)

      S.expects(:increment)
        .with('routing.error')

      subject.generate_key(fake_env).should == nil
    end

  end

end