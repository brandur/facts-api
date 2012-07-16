require "test_helper"

module Facts
  module Models
    describe Category do
      let(:category)  { Category.new(name: "Canada", slug: "canada") }

      it "is valid" do
        category.valid?.must_equal true
      end

      it "validates slug format" do
        Models::Category.new(name: "x", slug: "world").valid?.must_equal true
        Models::Category.new(name: "x", slug: "world2").valid?.must_equal true
        Models::Category.new(name: "x", slug: "0world").valid?.must_equal true
        Models::Category.new(name: "x", slug: "puerto-rico").valid?.must_equal true

        Models::Category.new(name: "x", slug: "World").valid?.must_equal false
        Models::Category.new(name: "x", slug: "world%").valid?.must_equal false
        Models::Category.new(name: "x", slug: "world-").valid?.must_equal false
        Models::Category.new(name: "x", slug: "-world").valid?.must_equal false

        # 1 character is not valid -- may want to fix this eventually
        Models::Category.new(name: "x", slug: "x").valid?.must_equal false
      end

      describe "scopes" do
        before do
          category.save
        end

        it "has searches" do
          Category.search("canada").first.wont_be_nil
          Category.search("canada").first.slug.must_equal "canada"
          Category.search("sri lanka").first.must_be_nil
        end
      end
    end
  end
end
