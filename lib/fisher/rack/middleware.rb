module Fisher
  module Rack
    class Middleware
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      VALID_METHODS  = ['GET', 'HEAD', 'POST', 'PUT', 'DELETE'].freeze

      # Initializes the middleware.
      #
      # app      - The next Rack app in the pipeline.
      # options  - Hash of options.
      #            :stats        - Optional StatsD client.
      #            :hostname     - Optional String hostname. Set to nil
      #                            to exclude.
      #            :stats_prefix - Optional String prefix for StatsD keys.
      #                            Default: "rack"
      def initialize(app, options = {})
        @app = app

        if @stats = options[:stats]
          prefix = [options[:stats_prefix] || :rack]
          if options.has_key?(:hostname)
            prefix << options[:hostname].gsub(/\./, '_') unless options[:hostname].nil?
          else
            prefix << `hostname -s`.chomp.gsub(/\./, '_')
          end
          @stats_prefix = prefix.join(".")
        end
      end

      # called immediately after a request to record statistics
      def record_request(status, env)
        now = Time.now
        diff = (now - @start)

        if @stats
          @stats.timing("#{@stats_prefix}.response_time", diff * 1000)
          if VALID_METHODS.include?(env[REQUEST_METHOD])
            stat = "#{@stats_prefix}.response_time.#{env[REQUEST_METHOD].downcase}"
            @stats.timing(stat, diff * 1000)
          end

          if suffix = status_suffix(status)
            @stats.increment "#{@stats_prefix}.status_code.#{status_suffix(status)}"
          end
        end
      rescue => e
        warn "Middleware#record_request failed: #{e.inspect}"
      end

      def status_suffix(status)
        suffix = case status.to_i
          when 200 then :ok
          when 201 then :created
          when 202 then :accepted
          when 301 then :moved_permanently
          when 302 then :found
          when 303 then :see_other
          when 304 then :not_modified
          when 305 then :use_proxy
          when 307 then :temporary_redirect
          when 400 then :bad_request
          when 401 then :unauthorized
          when 402 then :payment_required
          when 403 then :forbidden
          when 404 then :missing
          when 410 then :gone
          when 422 then :invalid
          when 500 then :error
          when 502 then :bad_gateway
          when 503 then :node_down
          when 504 then :gateway_timeout
        end
      end

      # Body wrapper. Yields to the block when body is closed. This is used to
      # signal when a response is fully finished processing.
      class Body
        def initialize(body, &block)
          @body = body
          @block = block
        end

        def each(&block)
          if @body.respond_to?(:each)
            @body.each(&block)
          else
            block.call(@body)
          end
        end

        def close
          @body.close if @body.respond_to?(:close)
          @block.call
          nil
        end
      end

      # Rack entry point.
      def call(env)
        @start = Time.now

        status, headers, body = @app.call(env)
        body = Body.new(body) { record_request(status, env) }
        [status, headers, body]
      end
    end
  end
end
