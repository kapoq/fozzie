require 'fozzie/rack/middleware'

module Fozzie
  module Rails

    # Time and record each request through a given Rails app
    # This middlewware times server processing for a resource, not view render.
    class Middleware < Fozzie::Rack::Middleware

      # Generates the statistics key for the current path
      def generate_key(env)
        path_str = env['PATH_INFO']
        return nil unless path_str

        begin
          routing = (rails_version == 3 ? ::Rails.application.routes : ::ActionController::Routing::Routes)
          path    = routing.recognize_path(path_str)
          stat    = [path[:controller], path[:action], "render"].join('.')
          stat
        rescue ActionController::RoutingError => exc
          S.increment "routing.error"
          nil
        rescue => exc
          nil
        end
      end

      def rails_version
        ::Rails.version.to_i
      end

    end
  end
end