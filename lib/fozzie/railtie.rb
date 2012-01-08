module Fozzie
  module Rack
    class Railtie < Rails::Railtie

      initializer "fozzie.rack.insert_middleware" do |app|
        app.config.middleware.use "Fozzie::Rails::Middleware"
      end

    end
  end
end