require "test_helper"

module Facts
  module Serializers
    describe FactSerializer do
      let(:attrs) { { id: nil, content: "The world is big." } }
      let(:fact) do
        Models::Fact.new(attrs).tap do |f|
          f.category = Models::Category.new(name: 'World', slug: 'world')
        end
      end

      it "serializes with :api" do
        FactSerializer.new(:api).serialize(fact).must_equal(
          attrs.merge(created_at: nil, category:
            { id: nil, category_id: nil, name: 'World', slug: 'world' }
          )
        )
      end

      it "serializes with :category_nested" do
        FactSerializer.new(:category_nested).serialize(fact).must_equal attrs
      end
    end
  end
end
