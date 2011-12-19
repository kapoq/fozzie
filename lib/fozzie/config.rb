require "fozzie/configuration"

module Fozzie
  module Config

    def c
      config
    end

    def config(&block)
      @config ||= Configuration.new
    end

    def configure(&block)
      yield c if block_given?
    end

  end
end