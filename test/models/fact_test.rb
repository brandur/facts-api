require "test_helper"

module Facts
  module Models
    describe Fact do
      let(:fact) { Fact.new(id: 1, category_id: 1, content: "The world is **big**.") }

      it "is valid" do
        fact.valid?.must_equal true
      end

      describe "scopes" do
        let(:category)  { Category.new(id: 1, name: "World", slug: "world") }

        before do
          category.save
          fact.save
        end

        it "has random scope" do
          Fact.random.first.content.must_equal fact.content
        end

        it "has searches" do
          Fact.search("BIG").first.content.must_equal fact.content
          Fact.search("sri lanka").first.must_be_nil
        end
      end
    end
  end
end
