module Facts
  module Api
    module Helpers
      @@mtx = Mutex.new

      def auth
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
      end

      def auth_credentials
        auth.provided? && auth.basic? ? auth.credentials : nil
      end

      def authorized?
        auth_credentials == [ "", Config.http_api_key ]
      end

      def authorized!
        unless authorized?
          log :not_authorized, credentials: auth_credentials
          error!("401 Unauthorized", 401)
        end
      end

      def log(event, attrs)
        str = event.to_s
        attrs.each { |k, v| str += " #{k}=#{v}" }
        @@mtx.synchronize { $stdout.puts(str) }
      end

      def require_params!(*keys)
        keys.each do |key|
          error!("Require parameter: #{key}", 422) unless params[key]
        end
      end
    end
  end
end
