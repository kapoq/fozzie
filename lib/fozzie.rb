require "fozzie/configuration"
require "fozzie/connection"
require "fozzie/methods"
require "fozzie/version"

module Fozzie
  extend Fozzie::Methods
  
  def self.c
    config
  end
  
  def self.config
    @config ||= Configuration.new
  end
  
end