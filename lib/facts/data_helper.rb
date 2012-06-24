require "uri"

module Facts
  module DataHelper
    extend self

    def init
      #ActiveRecord::Base.logger = Logger.new($stdout)
      ActiveRecord::Base.establish_connection(Facts::Config.database_url)
    end
  end
end
