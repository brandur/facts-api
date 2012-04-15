require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"
require "rack/test"

require "facts"

ActiveRecord::Base.establish_connection database: "facts-api-test", adapter: "postgresql"
