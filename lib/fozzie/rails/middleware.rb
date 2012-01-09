require 'fozzie/rack/middleware'

module Fozzie
  module Rails
    class Middleware < Fozzie::Rack::Middleware

      def generate_key(env)
        s = env['PATH_INFO']
        return nil if s.nil?
        begin
          path = ActionController::Routing::Routes.recognize_path(s)
          [path[:controller], path[:action], "render"].join('.')
        rescue => exc
          nil
        end
      end

    end
  end
end