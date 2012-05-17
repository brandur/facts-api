require "uri"

module Facts
  module DataHelper
    extend self

    def init
      #ActiveRecord::Base.logger = Logger.new($stdout)
      ActiveRecord::Base.establish_connection(Facts::Config.database_url)
=begin
      url = URI(Facts::Config.database_url)
      options =  {
        adapter: url.scheme,
        host: url.host,
        port: url.port,
        database: url.path[1..-1],
        username: url.user,
        password: url.password,
      }
      options[:adapter] = "postgresql" if url.scheme == "postgres"
      ActiveRecord::Base.logger = Logger.new($stdout)
      ActiveRecord::Base.establish_connection(options)
=end
    end
  end
end
