root = File.expand_path('../', File.dirname(__FILE__))
lib  = File.expand_path('lib', root)
$:.unshift(root, lib)

require 'fozzie'

RSpec.configure do |config|
  config.mock_with :mocha
end