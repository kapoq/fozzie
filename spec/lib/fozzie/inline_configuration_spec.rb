require 'spec_helper'

describe Fozzie::Inline do
  class ExampleClass
    include Fozzie::Inline

    time_with_fozzie
    def self.example_class_method
      # TODO...
    end
    
    time_with_fozzie
    def example_instance_method
      # TODO...
    end

    def example_method_with_fozzie_logging
      # ??
    end
  end
  
  let(:example) { ExampleClass.new }
 
  it "logs the duration of a given instance method" do
    S.expects(:time_for)
    example.example_instance_method
  end

  it "logs the duration of a given class method" do
    S.expects(:time_for)
    ExampleClass.example_class_method
  end

  
  let(:dummy_class) { Class.new { include Fozzie::Inline } }
  
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
    it "sets up an alias method chain for the object with the given method name and the suffix :fozzie_logging" do
      dummy_class.expects(:alias_method_chain).with(:foo, :fozzie_logging)
      dummy_class.register_method(:foo, dummy_class)
    end
  end
end
