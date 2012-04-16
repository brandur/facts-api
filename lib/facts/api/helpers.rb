module Facts
  module Api
    module Helpers
      def authenticate!
      end

      def require_params!(*keys)
        keys.each do |key|
          error!("Require parameter: #{key}", 422) unless params[key]
        end
      end
    end
  end
end
