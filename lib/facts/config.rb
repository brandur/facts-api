module Facts
  module Config
    extend self

    def database_url
      @database_url ||= env!("DATABASE_URL")
    end

=begin
    def port
      @port ||= env("PORT") || 7080
    end

    def http_user
      @http_user ||= env!("YAKEI_HTTP_USER")
    end

    def http_pass
      @http_pass ||= env!("YAKEI_HTTP_PASS")
    end
=end

    private

    def env(k)
      ENV[k] unless ENV[k].blank?
    end

    def env!(k)
      env(k) || raise("missing_environment=#{k}")
    end

  end
end
