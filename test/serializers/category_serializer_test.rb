require "test_helper"

module Facts
  module Serializers
    describe CategorySerializer do
      before do
        @category = Models::Category.new(name: "World", slug: "world").tap do |c|
          c.facts << Models::Fact.new(content: "The world is big.")
        end
      end

      it "serializes with :v0" do
        CategorySerializer.new(:v0).serialize(@category).must_equal(
          id: nil, name: "World", slug: "world", facts: [
            { id: nil, content: "The world is big." }
          ])
      end
    end
  end
end
