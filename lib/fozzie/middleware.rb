module Fozzie
  class Middleware

    # @param [Hash]
    def initialize(app)
      @app = app
    end

    # @param [Rack::Application]
    def call(env)
      Rails.logger.info env.inspect
      Rails.logger.info @app.inspect
      #k = generate_key
      #S.time_to_do k do
        @app.call(env)
      #end
    end

    def generate_key
      [controller_path.split('/'), action_name, "render"].flatten.join('.')
    end

  end
end