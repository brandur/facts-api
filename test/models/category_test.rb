require "test_helper"

module Facts
  module Models
    describe Category do
      let(:category) do
        Models::Category.new(name: 'World', slug: 'world').tap do |c|
          c.categories.new(name: "Canada", slug: "canada")
        end
      end

      it "is valid" do
        category.valid?.must_equal true
      end

      describe "scopes" do
        before do
          category.save if category.new_record?
        end

        it "has top scope" do
          Category.top.count.must_equal 1
          Category.top.first.slug.must_equal "world"
        end

        it "has searches" do
          Category.search("canada").first.slug.must_equal "canada"
          Category.search("sri lanka").first.must_be_nil
        end
      end
    end
  end
end
