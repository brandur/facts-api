require "test_helper"

module Facts
  module Serializers
    describe CategorySerializer do
      let(:category) {
        Models::Category.new(id: 1, name: "World", slug: "world").tap do |c|
          c.facts <<
            Models::Fact.new(id: 1, content: "The world is big.")
          c.children <<
            Models::Category.new(id: 2, name: "Canada", slug: "canada")
        end
      }

      it "serializes with :api" do
        CategorySerializer.new(:api).serialize(category).must_equal(
          id: 1, category_id: nil, name: "World", slug: "world", categories: [
            { id: 2, name: "Canada", slug: "canada" }
          ], facts: [
            { id: 1, content: "The world is big." }
          ])
      end

      it "serializes with :category_nested" do
        CategorySerializer.new(:category_nested).serialize(category).must_equal(
          { id: 1, name: "World", slug: "world" }
        )
      end

      it "serializes with :fact_nested" do
        CategorySerializer.new(:fact_nested).serialize(category).must_equal(
          { id: 1, name: "World", slug: "world", category_id: nil })
      end
    end
  end
end
