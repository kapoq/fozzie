ENV['RACK_ENV'] ||= 'test'

root = File.expand_path('../', File.dirname(__FILE__))
lib  = File.expand_path('lib', root)
$:.unshift(root, lib)

require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.mock_with :mocha
end

require 'fozzie'

Fozzie.configure do |config|
  config.host    = '127.0.0.1'
  config.port    = 8809
end