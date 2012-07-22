require "test_helper"

module Facts
  module Serializers
    describe FactSerializer do
      before do
        @fact = Models::Fact.new(content: "The world is big.")
        stub(@fact).category { Models::Category.new(name: 'World', slug: 'world') }
      end

      it "serializes with :v0" do
        FactSerializer.new(:v0).serialize(@fact).must_equal(
          { id: nil, content: "The world is big.", created_at: nil, category:
            { id: nil, name: "World", slug: "world" }
          })
      end
    end
  end
end
