require "bundler/setup"
Bundler.require

require "rake/testtask"

$: << "lib"
require "facts"

DB = Sequel.connect(Facts::Config.database_url)
DB.loggers << Logger.new($stdout)
require "facts/models/category"
require "facts/models/fact"

Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :environment do
end

task :truncate => :environment do
  Sequel::Model.db["TRUNCATE facts"]
  Sequel::Model.db["TRUNCATE categories"]
end

namespace :db do
  task :migrate => :environment do
    if ENV["STEPS"]
      ActiveRecord::Migrator.forward("db/migrate", ENV["STEPS"].to_i)
    else
      ActiveRecord::Migrator.migrate("db/migrate", ENV["VERSION"])
    end
  end

  task :rollback => :environment do
    if ENV["STEPS"]
      ActiveRecord::Migrator.rollback("db/migrate", ENV["STEPS"].to_i)
    else
      ActiveRecord::Migrator.down("db/migrate", ENV["VERSION"])
    end
  end
end
