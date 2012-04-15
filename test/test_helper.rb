require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"
require "rack/test"

require "facts"

ActiveRecord::Base.establish_connection database: "facts-api-test", adapter: "postgresql"

# should probably be a before(:each)
ActiveRecord::Base.connection.execute("TRUNCATE facts")
ActiveRecord::Base.connection.execute("TRUNCATE categories")
