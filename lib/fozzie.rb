require "fozzie/config"
require "fozzie/connection"
require "fozzie/methods"
require "fozzie/version"

module Fozzie
  extend Fozzie::Methods, Fozzie::Config
end