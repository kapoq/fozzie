require "fozzie/config"
require "fozzie/classes"
require "fozzie/version"
require "fozzie/rack/middleware"
require "fozzie/rails/middleware"

module Fozzie
  extend Fozzie::Config
  include Fozzie::Classes
end