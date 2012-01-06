require "fozzie/config"
require "fozzie/classes"
require "fozzie/version"
require "fozzie/middleware"

module Fozzie
  extend Fozzie::Config
  include Fozzie::Classes
end