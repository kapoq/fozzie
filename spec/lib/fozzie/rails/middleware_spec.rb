require 'spec_helper'
require 'action_controller'

describe Fozzie::Rails::Middleware do
  let(:path_info) { '/somewhere/railsy' }
  let(:fake_env)  { ({ 'PATH_INFO' => path_info }) }
  let(:routing)   { mock 'routing' }

  subject do
    RailsApp = Class.new do
      def call(env); env end
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
      subject.stubs(:routing_lookup).returns(routing)
      routing.expects(:recognize_path)
        .with(path_info)
        .returns({:controller => 'somewhere', :action => 'railsy'})

      subject.generate_key(fake_env).should == 'somewhere.railsy.render'
    end

    it "returns nil on routing error" do
      subject.stubs(:routing_lookup).returns(routing)
      routing.expects(:recognize_path)
        .with(path_info)
        .raises(RuntimeError)

      subject.generate_key(fake_env).should == nil
    end

  end

  describe "rails 3" do
    let!(:rails)    { RailsApp.stubs(:application).returns(Class.new) }
    let!(:version)  { RailsApp.stubs(:version).returns("3.1.1") }

    it "#generate_key" do
      subject.stubs(:routing_lookup).returns(routing)
      routing.expects(:recognize_path)
        .with(path_info)
        .returns({:controller => 'somewhere', :action => 'railsy'})

      subject.generate_key(fake_env).should == 'somewhere.railsy.render'
    end

    it "returns nil on error" do
      subject.stubs(:routing_lookup).returns(routing)
      routing.expects(:recognize_path)
        .with(path_info)
        .raises(RuntimeError)

      subject.generate_key(fake_env).should == nil
    end

    it "returns nil on routing error" do
      subject.stubs(:routing_lookup).returns(routing)
      routing.expects(:recognize_path)
        .with(path_info)
        .raises(RuntimeError)

      S.expects(:increment).with('routing.error')

      subject.generate_key(fake_env).should == nil
    end

  end

end