require "bundler/setup"
Bundler.require

$: << "./lib"
require "facts"

$stdout.sync = true

Facts::DataHelper.init

use Rack::Instruments
run Facts::ApiAggregate
