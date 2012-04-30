require 'spec_helper'

module Fozzie
  module Inline

    def self.included(base)
      base.class_eval { extend ClassMethods }
    end

    module ClassMethods

      def time_with_fozzie
        @time_next_method_added = true
      end
      
      def time_next_method_added?
        @time_next_method_added ||= false
      end

      def method_added(*args)
        if time_next_method_added?
          register_method(*args)
        end
      end

      def register_method(m)
        @time_next_method_added = false
        alias_method_chain m, :fozzie_logging
      end

      # TODO: import from alias_method_chain
      def alias_method_chain(target, feature)
        # Strip out punctuation on predicates or bang methods since
        # e.g. target?_without_feature is not a valid method name.
        aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
        yield(aliased_target, punctuation) if block_given?

        with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"

        alias_method without_method, target
        alias_method target, with_method

        case
          when public_method_defined?(without_method)
            public target
          when protected_method_defined?(without_method)
            protected target
          when private_method_defined?(without_method)
            private target
        end
      end
    end

  end
end

describe Fozzie::Inline do

  class ExampleClass
    include Fozzie::Inline

    time_with_fozzie
    def example_method
      # TODO...
    end

    def example_method_with_fozzie_logging
      # ??
    end

  end

  let(:example) { ExampleClass.new }
  let(:dummy_class) { Class.new { include Fozzie::Inline } }

  it "logs the duration of a given method" do
    S.expects(:time_for)
    example.example_method
  end
  
  describe "#time_next_method_added?" do
    it "returns false by default" do
      dummy_class.time_next_method_added?.should be_false
    end
  end

  describe ".time_with_fozzie" do
    it "sets #time_next_method_added? to true" do
      dummy_class.time_with_fozzie
      dummy_class.time_next_method_added?.should be_true
    end
  end

  describe ".method_added" do
    context "when time_with_fozzie is true" do
      before do
        dummy_class.stubs(:time_next_method_added? => true)
      end
      
      it "calls .register_method with the arguments" do
        dummy_class.expects(:register_method).with(:foo, anything)
        dummy_class.send(:define_method, :foo, lambda {})
      end
    end
    
    context "when time_next_method_added? is false" do
      before do
        dummy_class.stubs(:time_next_method_added? => false)
      end
      
      it "does not call .register_method" do
        dummy_class.expects(:register_method).never
        dummy_class.send(:define_method, :foo, lambda {})
      end
    end
  end

  describe ".register_method" do
    it "sets up an alias method chain for the object with the given method name and the suffix '_without_fozzie_logging'" do
      dummy_class.expects(:alias_method_chain).with(:foo, :fozzie_logging)
      dummy_class.send(:define_method, :foo, lambda {})
    end
  end
end
