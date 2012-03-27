require 'spec_helper'
require 'sinatra/base'
require 'rack/test'

describe Fozzie::Rack::Middleware do

  subject do
    unless defined?(RackApp)
      RackApp = Class.new { def call(env); env end } 
    end
    Fozzie::Rack::Middleware.new RackApp.new
  end

  it { should respond_to(:call) }
  it { should respond_to(:generate_key) }

  describe "subject" do
    it "returns env on call for testing" do
      subject.call({}).should == {}
    end
  end

  describe "#call" do

    it "ignored stats request when path not valid" do
      fake_env = { 'PATH_INFO' => '' }
      subject.expects(:call_without_timer).with(fake_env)
      subject.call(fake_env)
    end

    it "passes request with timer on index" do
      fake_env = { 'PATH_INFO' => '/' }
      subject.expects(:call_with_timer).with('index.render', fake_env)
      subject.call(fake_env)
    end

    it "passes request with timer on full path" do
      fake_env = { 'PATH_INFO' => '/somewhere/nice' }
      subject.expects(:call_with_timer).with('somewhere.nice.render', fake_env)
      subject.call(fake_env)
    end

    it "passes request onto app" do
      envs = ['', '/', '/somewhere/nice'].each do |p|
        fake_env = { 'PATH_INFO' => p }
        subject.app.expects(:call).with(fake_env)
        subject.call(fake_env)
      end
    end

  end

  describe "#generate_key" do

    it "returns nil when applicable" do
      fake_env = { 'PATH_INFO' => '' }
      subject.generate_key(fake_env).should be_nil
    end

    it "returns index when root" do
      fake_env = { 'PATH_INFO' => '/' }
      subject.generate_key(fake_env).should == 'index.render'
    end

    it "returns dotted value" do
      fake_env = { 'PATH_INFO' => '/somewhere/nice' }
      subject.generate_key(fake_env).should == 'somewhere.nice.render'
    end

  end

end

describe "Sinatra Server with Middleware" do
  include Rack::Test::Methods

  def app
    Sinatra.new do
      set :environment, :test
      use Fozzie::Rack::Middleware
      get('/') { "echo" }
      get('/somewhere/nice') { "echo" }
    end
  end

  it "sends stats request on root" do
    S.expects(:timing).with('index.render', any_parameters)
    get '/'
    last_response.should be_ok
    last_response.body.should == 'echo'
  end

  it "sends stats request on nested path" do
    S.expects(:timing).with('somewhere.nice.render', any_parameters)
    get '/somewhere/nice'
    last_response.should be_ok
    last_response.body.should == 'echo'
  end

end