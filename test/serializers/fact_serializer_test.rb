require "test_helper"

module Facts
  module Serializers
    describe FactSerializer do
      let(:fact) do
        Models::Fact.new(id: 1, content: "The world is big.").tap do |f|
          f.category = Models::Category.new(id: 1, name: 'World', slug: 'world')
        end
      end

      it "serializes with :api" do
        FactSerializer.new(:api).serialize(fact).must_equal(
          { id: 1, content: "The world is big.", created_at: nil, category:
            { id: 1, category_id: nil, name: "World", slug: "world" }
          })
      end

      it "serializes with :nested" do
        FactSerializer.new(:nested).serialize(fact).must_equal(
          { id: 1, content: "The world is big." })
      end
    end
  end
end
