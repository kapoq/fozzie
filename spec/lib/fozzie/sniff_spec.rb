require 'spec_helper'
require 'fozzie/sniff'

describe Fozzie::Sniff do

  subject do
    class FooBar

      _monitor
      def self.bar!; :bar end

      _monitor
      def self.koala(hsh = {}); hsh end

      def self.badger; :cares end

      _monitor
      def foo; :foo end

      _monitor
      def sloth(a, b, c); [a,b,c] end

      def honeybadger; :dontcare end

      _monitor
      def proxy_woxy
        yield(:proxy) if block_given?
      end

    end

    FooBar
  end

  context "environments" do

    it "is disabled in test" do
      Fozzie.c.stubs(:env).returns('test')
      S.expects(:time_for).with(['foo_bar', 'bar!']).never

      subject.bar!
    end

    it "is enabled in development" do
      Fozzie.c.stubs(:env).returns('development')
      S.expects(:time_for).with(['foo_bar', 'bar!'])

      subject.bar!
    end

  end

  context 'class methods' do
    let!(:env) { Fozzie.c.stubs(:env).returns('development') }

    it "aliases methods for monitoring" do
      subject.methods.grep(/bar/).should eq [:bar!, :"bar_with_monitor!", :"bar_without_monitor!"]
    end

    it "behaves like original" do
      subject.bar!.should eq :bar
    end

    it "utilises Fozzie" do
      S.expects(:time_for).with(['foo_bar', 'bar!'])

      subject.bar!
    end

    it "handles arguments" do
      h = { drop: 'bear' }
      subject.koala(h).should eq h
    end

    it "does not monitor when mapped" do
      S.expects(:time_for).with(['foo_bar', 'badger']).never

      subject.badger.should eq :cares
    end

  end

  context 'instance methods' do

    it "aliases methods for monitoring" do
      subject.new.methods.grep(/foo/).should eq [:foo, :foo_with_monitor, :foo_without_monitor]
    end

    it "behaves like original" do
      subject.new.foo.should eq :foo
    end

    it "utilises Fozzie" do
      S.expects(:time_for).with(['foo_bar', 'foo'])

      subject.new.foo
    end

    it "handles arguments" do
      a = [:slow, :slower, :slowest]
      subject.new.sloth(*a).should eq a
    end

    it "does not monitor when mapped" do
      S.expects(:time_for).with(['foo_bar', 'honeybadger']).never

      subject.new.honeybadger.should eq :dontcare
    end

    it "yields block when given" do
      S.expects(:time_for).with(['foo_bar', 'proxy_woxy'])

      subject.new.proxy_woxy do |a|
        puts :hey
        a
      end.should eq :proxy
    end

  end

end
