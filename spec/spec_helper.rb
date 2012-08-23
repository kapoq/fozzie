ENV['RACK_ENV'] ||= 'test'

# Basic path registers
root   = File.expand_path('../', File.dirname(__FILE__))
lib    = File.expand_path('lib', root)
$:.unshift(root, lib)

# Shared Examples
Dir[File.expand_path('spec/shared_examples/*.rb')].each {|r| require r }

require 'fozzie'

Fozzie.configure do |config|
  config.host    = '127.0.0.1'
  config.port    = 8809
end