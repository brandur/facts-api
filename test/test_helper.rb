require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"
require "rack/test"
require "rr"

require "facts"

ActiveRecord::Base.establish_connection database: "facts-api-test", adapter: "postgresql"

# should probably be a before(:each)
ActiveRecord::Base.connection.execute("TRUNCATE facts")
ActiveRecord::Base.connection.execute("TRUNCATE categories")

class MiniTest::Spec
  include RR::Adapters::TestUnit
end

class Hash
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
end

def serialize_generic(serializer, form, obj)
  out = serializer.new(form).serialize(obj)
  if obj.respond_to?(:map)
    out.map{ |o| o.stringify_keys! }
  else
    out.stringify_keys!
  end
end
