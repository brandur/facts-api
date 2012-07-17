module Facts
  module Api
    module Helpers
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
        raise Unauthorized unless authorized?
      end

      def log(action, attrs = {})
        Slides.log(action, attrs.merge!(id: request.id))
      end

      def require_params!(*keys)
        keys.each do |key|
          unless params[key]
            raise BadRequest.new("Bad request: require parameter: #{key}")
          end
        end
      end
    end
  end
end
