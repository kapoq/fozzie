require 'ostruct'

module Fozzie

  class Configuration < OpenStruct

    def initialize(args = {})
      super self.class.default_configuration.merge(args)
    end

    private

    def self.default_configuration
      {
        :host => '127.0.0.1',
        :port => 8081
      }.dup
    end

  end

end