require 'fozzie/rack/middleware'

module Fozzie
  module Rails
    class Middleware < Fozzie::Rack::Middleware

      def generate_key(env)
        s = env['PATH_INFO']
        return nil if s.nil?
        path = ActionController::Routing::Routes.recognize_path(s)
        [path[:controller], path[:action], "render"].join('.')
      end

    end
  end
end