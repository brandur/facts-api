require "test_helper"

module Facts
  module Models
    describe Category do
      let(:category)  { Category.new(name: "World", slug: "world") }
      let(:category2) { Category.new(name: "Canada", slug: "canada", parent: category) }
      let(:category3) { Category.new(name: "Alberta", slug: "alberta", parent: category2) }

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

      describe "paths" do
        before do
          category.save
          category2.save
          category3.save
        end

        it "has a path" do
          category.path.must_equal "world"
          category.children.first.path.must_equal "world/canada"
        end

        it "finds categories by path" do
          Category.find_by_path!("world/canada").slug.must_equal "canada"
          Category.find_by_path!("world/canada/alberta").slug.must_equal "alberta"
        end

        it "raises an error when using find_by_path!" do
          lambda{ Category.find_by_path!("world/canada/alberta/calgary") }.must_raise \
            NotFound
        end
      end

      describe "scopes" do
        before do
          category.save
          category2.save
          category3.save
        end

        it "has top scope" do
          Category.top.count.must_equal 1
          Category.top.first.slug.must_equal "world"
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
