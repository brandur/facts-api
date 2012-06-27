require "bundler/setup"
Bundler.require

require "rake/testtask"

$: << "lib"
require "facts"

Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :environment do
  DB = Sequel.connect(Facts::Config.database_url)
  require "facts/models/category"
  require "facts/models/fact"
end

task :truncate => :environment do
  Facts::Models::Fact.delete
  Facts::Models::Category.delete
  puts "Truncated facts/categories"
end
