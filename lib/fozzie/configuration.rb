require 'ostruct'
require 'core_ext/hash'

module Fozzie

  # Fozzie configuration allows assignment of global properties
  # that will be used within the Fozzie codebase.
  class Configuration

    attr_accessor :env, :config_path, :host, :port

    def initialize(args = {})
      merge_and_assign_config(args)

      self
    end

    private

    # Handle the merging of the given configuaration, and the default config.
    # @return [Hash]
    def merge_and_assign_config(args = {})
      arg = self.class.default_configuration.merge(args.symbolize_keys)
      arg.delete_if {|key, val| !self.respond_to?(key.to_sym) }
      arg.merge!(config_from_yaml(args))
      arg.each {|a,v| self.send("#{a}=", v) }

      arg
    end

    # Default configuration settings
    # @return [Hash]
    def self.default_configuration
      en = 
      { :host => '127.0.0.1', :port => 8125, :config_path => '', :env => (ENV['RAILS_ENV'] || 'development') }.dup
    end

    def full_config_path(path)
      File.expand_path('config/fozzie.yml', path)
    end

    def config_from_yaml(args)
      fp = full_config_path(args[:config_path])
      return {} unless File.exists?(fp)
      YAML.load(File.open(fp))[args[:env]].symbolize_keys
    end

  end

end