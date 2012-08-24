require 'spec_helper'

module Fozzie
  describe BulkDsl do

    it_behaves_like "interface"

    describe "#initialize" do

      it "accepts and performs block" do
        BulkDsl.any_instance.should_receive(:foo)

        BulkDsl.new { foo }
      end

    end

    it "sends statistics in one call" do
      Fozzie.c.adapter.should_receive(:register).once

      BulkDsl.new do
        increment :foo
        decrement :bar
      end
    end

    it "scopes given block when arity provided" do
      Fozzie.c.adapter.should_receive(:register).once

      class Foo

        def send_stats
          BulkDsl.new do |s|
            s.increment random_value
            s.decrement random_value
          end
        end

        def random_value; rand end

      end

      Foo.new.send_stats
    end

  end
end