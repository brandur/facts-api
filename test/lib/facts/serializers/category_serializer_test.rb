require "test_helper"

module Facts
  module Serializers
    describe CategorySerializer do
      let(:attrs) { { id: nil, category_id: 1, name: 'World', slug: 'world' } }
      let(:category) do
        Models::Category.new(attrs).tap do |c|
          c.facts.new(content: "The world is big.")
        end
      end

      it "serializes with :api" do
        CategorySerializer.new(:api).serialize(category).must_equal(
          attrs.merge(facts: [
            { id: nil, content: "The world is big." }
          ])
        )
      end

      it "serializes with :fact_nested" do
        CategorySerializer.new(:fact_nested).serialize(category).must_equal attrs
      end
    end
  end
end
