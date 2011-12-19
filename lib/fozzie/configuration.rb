require 'ostruct'
require 'core_ext/hash'

module Fozzie

  # Fozzie configuration allows assignment of global properties
  # that will be used within the Fozzie codebase.
  class Configuration < OpenStruct

    def initialize(args = {})
      super self.class.merge_config(args)
    end

    private

    # Handle the merging of the given configuaration, and the default config.
    # @return [Hash]
    def self.merge_config(args = {})
      arg = self.default_configuration.merge(args.symbolize_keys)
      arg.delete_if {|key, val| !self.default_configuration.keys.include?(key.to_sym) }
      arg
    end

    # Default configuration settings
    # @return [Hash]
    def self.default_configuration
      {
        :host    => '127.0.0.1',
        :port    => 999,
        :via     => :tcp,
        :timeout => 100
      }.dup
    end

  end

end