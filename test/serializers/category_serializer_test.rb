require "test_helper"

module Facts
  module Serializers
    describe CategorySerializer do
      let(:category) {
        Models::Category.new(id: 1, name: "World", slug: "world").tap do |c|
          c.facts <<
            Models::Fact.new(id: 1, content: "The world is big.")
        end
      }

      it "serializes with :api" do
        CategorySerializer.new(:api).serialize(category).must_equal(
          id: 1, name: "World", slug: "world", facts: [
            { id: 1, content: "The world is big." }
          ])
      end

      it "serializes with :nested" do
        CategorySerializer.new(:nested).serialize(category).must_equal(
          { id: 1, name: "World", slug: "world" })
      end
    end
  end
end
