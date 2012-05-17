module Facts
  module Api
    module Helpers
      @@mtx = Mutex.new

      def authenticate!
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
