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

      it "serializes with :v0" do
        CategorySerializer.new(:v0).serialize(category).must_equal(
          id: 1, name: "World", slug: "world", facts: [
            { id: 1, content: "The world is big." }
          ])
      end
    end
  end
end
