require "fisher/rack/version"
require "fisher/rack/middleware"

require "fisher/rack/railtie" if defined?(Rails)

module Fisher
  module Rack
    class << self
      def statsd=(client)
        @statsd = client
      end

      def statsd
        @statsd
      end
    end
  end
end
