require "test_helper"

module Facts
  module Serializers
    describe FactSerializer do
      let(:fact) do
        Models::Fact.new(id: 1, content: "The world is big.").tap do |f|
          f.category = Models::Category.new(id: 1, name: 'World', slug: 'world')
        end
      end

      it "serializes with :v0" do
        FactSerializer.new(:v0).serialize(fact).must_equal(
          { id: 1, content: "The world is big.", created_at: nil, category:
            { id: 1, name: "World", slug: "world" }
          })
      end
    end
  end
end
