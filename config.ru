require "bundler/setup"
Bundler.require

$: << "./lib"
require "facts"

$stdout.sync = true

DB = Sequel.connect(Facts::Config.database_url)
DB.loggers << Logger.new($stdout)
require "facts/models/category"
require "facts/models/fact"

use Rack::Instruments
run Facts::ApiAggregate
