require 'yaml'
require 'core_ext/hash'
require 'sys/uname'
require 'timeout'

module Fozzie

  # Fozzie configuration allows assignment of global properties
  # that will be used within the Fozzie codebase.

  class Configuration
    include Sys

    attr_accessor :env, :config_path, :host, :port, :appname, :namespaces, :timeout, :monitor_classes, :sniff_envs, :ignore_prefix, :prefix, :provider

    def initialize(args = {})
      merge_and_assign_config(args)
      self.adapter
      self.origin_name
    end

    def adapter
      @adapter ||= eval("Fozzie::Adapter::#{@provider}").new
    rescue NoMethodError
      raise AdapterMissing, "Adapter could not be found for given provider #{@provider}"
    end

    def disable_prefix
      @ignore_prefix = true
    end

    # Returns the prefix for any stat requested to be registered
    def data_prefix
      return nil if @ignore_prefix
      return @data_prefix if @data_prefix

      data_prefix = @prefix.collect do |me|
        (me.kind_of?(Symbol) && self.respond_to?(me.to_sym) ? self.send(me) : me.to_s)
      end

      data_prefix = data_prefix.collect do |s|
        s.empty? ? nil : s.gsub(adapter.class::DELIMETER, '-')
      end.compact.join(adapter.class::DELIMETER).strip

      @data_prefix ||= (data_prefix.empty? ? nil : data_prefix)
    end

    # Returns the origin name of the current machine to register the stat against
    def origin_name
      @origin_name ||= Uname.nodename
    end

    def sniff?
      self.sniff_envs.collect(&:to_sym).include?(self.env.to_sym)
    end

    private

    # Handle the merging of the given configuaration, and the default config.
    def merge_and_assign_config(args = {})
      arg = self.class.default_configuration.merge(args.symbolize_keys)
      arg.merge!(config_from_yaml(arg))
      arg.each {|a,v| self.send("#{a}=", v) if self.respond_to?(a.to_sym) }

      arg
    end

    # Default configuration settings
    def self.default_configuration
      {
        :host            => '127.0.0.1',
        :prefix          => [:appname, :origin_name, :env],
        :port            => 8125,
        :config_path     => '',
        :env             => (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'),
        :appname         => '',
        :namespaces      => %w{Stats S Statistics Warehouse},
        :timeout         => 0.5,
        :monitor_classes => [],
        :sniff_envs      => [:development, :staging, :production],
        :ignore_prefix   => false,
        :provider        => :Statsd
      }.dup
    end

    # Loads the configuration from YAML, if possible
    def config_from_yaml(args)
      fp = full_config_path(args[:config_path])
      return {} unless File.exists?(fp)
      cnf = YAML.load(File.open(fp))[args[:env]]
      (cnf.kind_of?(Hash)) ? cnf.symbolize_keys : {}
    end

    # Returns the absolute file path for the Fozzie configuration, relative to the given path
    def full_config_path(path)
      File.expand_path('config/fozzie.yml', path)
    end

  end

end