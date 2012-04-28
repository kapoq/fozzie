require 'json'
require 'fozzie/mill'

module Fozzie
  module Rails
    class Engine < ::Rails::Engine

      endpoint Proc.new { |env|
        Fozzie::Mill.register(env['QUERY_STRING'].gsub('d=', ''))
        [201, {"Content-Type" => "text/html"}, [""]]
      }

    end
  end
end