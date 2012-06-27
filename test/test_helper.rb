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
    Facts::Models::Fact.delete
    Facts::Models::Category.delete

    Facts::Models::Fact.unrestrict_primary_key
    Facts::Models::Category.unrestrict_primary_key
  end

  def last_json
    JSON.parse(last_response.body)
  end
end

class Hash
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
end

def d
  require "debugger"
  debugger
end

def serialize_generic(serializer, form, obj)
  out = serializer.new(form).serialize(obj)
  if obj.respond_to?(:map)
    out.map{ |o| o.stringify_keys! }
  else
    out.stringify_keys!
  end
end
