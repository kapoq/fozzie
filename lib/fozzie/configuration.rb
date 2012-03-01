require 'core_ext/hash'
require 'resolv'
require 'timeout'

module Fozzie

  # Fozzie configuration allows assignment of global properties
  # that will be used within the Fozzie codebase.
  class Configuration

    attr_accessor :env, :config_path, :host, :port, :appname, :namespaces, :timeout

    def initialize(args = {})
      merge_and_assign_config(args)
      self.ip_from_host
      self.origin_name
      self
    end

    def data_prefix
      s = [appname, origin_name, env].collect {|s| s.empty? ? nil : s.gsub('.', '-') }.compact.join('.').strip
      (s.empty? ? nil : s)
    end

    def ip_from_host
      @ip_from_host ||= host_to_ip
    end

    def origin_name
      @origin_name ||= %x{uname -n}.strip
    end

    private

    # Handle the merging of the given configuaration, and the default config.
    # @return [Hash]
    def merge_and_assign_config(args = {})
      arg = self.class.default_configuration.merge(args.symbolize_keys)
      arg.delete_if {|key, val| !self.respond_to?(key.to_sym) }
      arg.merge!(config_from_yaml(arg))
      arg.each {|a,v| self.send("#{a}=", v) }

      arg
    end

    # Default configuration settings
    # @return [Hash]
    def self.default_configuration
      {
        :host        => '127.0.0.1',
        :port        => 8125,
        :config_path => '',
        :env         => (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'),
        :appname     => '',
        :namespaces  => %w{Stats S Statistics Warehouse},
        :timeout     => 5
      }.dup
    end

    def host_to_ip
      return self.host unless self.host.match(ip_address_regex).nil?
      ips = begin 
        Timeout.timeout(self.timeout) { Resolv.getaddresses(self.host) }
      rescue Timeout::Error => exc
        []
      end
      (ips.empty? ? "" : ips.compact.reject {|ip| ip.to_s.match(ip_address_regex).nil? }.first || "")
    end

    def ip_address_regex
      /^(?:\d{1,3}\.){3}\d{1,3}$/
    end

    def full_config_path(path)
      File.expand_path('config/fozzie.yml', path)
    end

    def config_from_yaml(args)
      fp = full_config_path(args[:config_path])
      return {} unless File.exists?(fp)
      cnf = YAML.load(File.open(fp))[args[:env]]
      (cnf.kind_of?(Hash)) ? cnf.symbolize_keys : {}
    end

  end

end