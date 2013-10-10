module Fisher
  module Rack
    class Railtie < Rails::Railtie
      initializer "fisher.rack.insert_middleware" do |app|
        app.config.middleware.use Fisher::Rack::Middleware, :stats => Fisher::Rack.statsd
      end
    end
  end
end
