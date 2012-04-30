require 'spec_helper'

module Fozzie
  module Inline

    def self.included(base)
      base.class_eval { extend ClassMethods }
    end

    module ClassMethods

      def time_with_fozzie
        @time_next_method_defined = true
      end
      
      def time_next_method_defined?
        @time_next_method_defined ||= false
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

  end

  let(:example) { ExampleClass.new }
  let(:dummy_class) { Class.new { include Fozzie::Inline } }

  it "logs the duration of a given method" do
    S.expects(:time_for)
    example.example_method
  end
  
  describe "#time_next_method_defined?" do
    
    it "returns false by default" do
      dummy_class.time_next_method_defined?.should be_false
    end

  end

  describe "#time_with_fozzie" do

    it "sets #time_next_method_defined? to true" do
      dummy_class.time_with_fozzie
      dummy_class.time_next_method_defined?.should be_true
    end

  end

end