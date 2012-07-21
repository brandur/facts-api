require "bundler/setup"
Bundler.require(:default, :test)

require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"

require "facts"

ENV["DATABASE_URL"] = "postgres://localhost/facts-api-test"
DB = Sequel.connect(Facts::Config.database_url)

require "facts/models/category"
require "facts/models/fact"

class MiniTest::Spec
  include RR::Adapters::TestUnit

  before do
    # delete faster than truncate for small data sets
    Facts::Models::Fact.delete
    Facts::Models::Category.delete

    Facts::Models::Fact.unrestrict_primary_key
    Facts::Models::Category.unrestrict_primary_key
  end

  def last_json
    JSON.parse(last_response.body)
  end
end

# disable Sequel logging in tests because it's extremely verbose
module ::Sequel
  class Database
    def log_yield(sql, args=nil)
      yield
    end
  end
end

def stringify_keys(hash)
  return hash unless hash.is_a?(Hash)

  hash.keys.each do |key|
    value = stringify_keys(hash.delete(key))
    value = value.map { |e| stringify_keys(e) } if value.is_a?(Array)
    hash[key.to_s] = value
  end
  hash
end

def serialize_generic(serializer, form, obj)
  out = serializer.new(form).serialize(obj)
  if obj.respond_to?(:map)
    out.map{ |o| stringify_keys(o) }
  else
    stringify_keys(out)
  end
end
