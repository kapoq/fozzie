ENV['RACK_ENV'] ||= 'test'

# Basic path registers
root   = File.expand_path('../', File.dirname(__FILE__))
lib    = File.expand_path('lib', root)
$:.unshift(root, lib)

# Shared Examples
Dir[File.expand_path('spec/shared_examples/*.rb')].each {|r| require r }

require 'fozzie'

module Fozzie
  class Adapter::TestAdapter
    def register(*params); end
    
    def delimeter; ""; end
    def safe_separator; ""; end
  end
end

Fozzie.configure do |config|
  config.host     = '127.0.0.1'
  config.port     = 8809
  config.adapter  = "TestAdapter"
end



