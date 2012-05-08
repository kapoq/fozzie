require 'spec_helper'
require 'fozzie/sniff'

describe Fozzie::Sniff do

  subject do
    class FooBar
      include Fozzie::Sniff

      _monitor
      def self.bar!
        :bar
      end

      _monitor
      def self.koala(hsh = {})
        hsh
      end

      def self.badger
        :cares
      end

      _monitor
      def foo
        :foo
      end

      _monitor
      def sloth(a, b, c)
        [a,b,c]
      end

      def honeybadger
        :dontcare
      end

    end

    FooBar
  end

  context 'class methods' do

    it "aliases methods for monitoring" do
      subject.methods.grep(/bar/).should eq [:bar!, :"bar_with_monitor!", :"bar_without_monitor!"]
    end

    it "behaves like original" do
      subject.bar!.should eq :bar
    end

    it "utilises Fozzie" do
      S.expects(:time_for).with(['FooBar', 'bar!'])

      subject.bar!
    end

    it "handles arguments" do
      h = { drop: 'bear' }
      subject.koala(h).should eq h
    end

    it "does not monitor when mapped" do
      S.expects(:time_for).with(['FooBar', 'badger']).never

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
      S.expects(:time_for).with(['FooBar', 'foo'])

      subject.new.foo
    end

    it "handles arguments" do
      a = [:slow, :slower, :slowest]
      subject.new.sloth(*a).should eq a
    end

    it "does not monitor when mapped" do
      S.expects(:time_for).with(['FooBar', 'honeybadger']).never

      subject.new.honeybadger.should eq :dontcare
    end

  end

end