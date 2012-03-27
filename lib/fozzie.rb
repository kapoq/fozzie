# Fozzie is an implementation of the Statsd statistics gathering tool,
# designed to make gathering stastistics from applications easy, fast, and effective.
#
# Configuration can be applied through a block and/or configuration file ('config/fozzie.yml')
#
# Fozzie provides automatic namespacing for the current environment, and host.
#
# Rack and Rails middleware is avaliable to gather statistics on the processing time of Controller actions.
#
module Fozzie

  require_relative 'fozzie/configuration'
  require_relative "fozzie/interface"
  require_relative "fozzie/version"

  require_relative "fozzie/rack/middleware"
  require_relative "fozzie/rails/middleware"

  class << self

    # Shortcut for `Fozzie.config`
    def c
      config
    end

    # Returns the current configuration. Creates configuration on first-time request
    def config
      @config ||= Configuration.new
    end

    # Allows the setting on valudes against the configuration
    #
    # `Fozzie.configure {|config| config.wat = :random }`
    def configure
      yield c if block_given?
    end

    # Set a logger
    def logger=(logger)
      @logger = logger
    end

    # Accessor for logger
    def logger
      @logger
    end

  end

  # Loads each namespace for registering statistics
  self.c.namespaces.each do |klas|
    Kernel.const_set(klas, Interface.instance) unless const_defined?(klas)
  end

end