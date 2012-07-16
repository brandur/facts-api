require "test_helper"

module Facts
  module Api
    describe "api v0 categories" do
      include Rack::Test::Methods

      before do
        ENV["FACTS_HTTP_API_KEY"] = "secret"
      end

      let(:category1) { Models::Category.new(id: 1, name: "World", slug: "world") }
      let(:category2) { Models::Category.new(id: 2, name: "Canada", slug: "canada", category_id: category1.id) }

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        mock(Models::Category).all { [category1, category2] }
        get "/v0/categories"
        last_response.status.must_equal 200
        last_json.must_equal serialize([category1, category2])
      end

      it "gets top" do
        mock(Models::Category).top { [category1] }
        get "/v0/categories/top"
        last_response.status.must_equal 200
        last_json.must_equal serialize([category1])
      end

      it "gets by path" do
        mock(Models::Category).find_by_path!("world/canada") { category1 }
        get "/v0/categories/world/canada"
        last_response.status.must_equal 200
        last_json.must_equal serialize(category1)
      end

      it "renders a 404" do
        get "/v0/categories/does-not-exist"
        last_response.status.must_equal 404
        last_json.must_equal({ "error" => "Not found" })
      end

      it "requires authentication to create a category" do
        attrs = { category_id: 1, name: "Canada", slug: "canada" }
        post "/v0/categories", category: attrs.to_json
        last_response.status.must_equal 401
      end

      it "creates new categories" do
        authorize "", "secret"
        attrs = { category_id: 1, name: "Canada", slug: "canada" }
        mock(Models::Category).create(attrs.stringify_keys!) { category2 }
        post "/v0/categories", category: attrs.to_json
        last_response.status.must_equal 201
        last_json.must_equal serialize(category2)
      end

      it "requires authentication to update a category" do
        attrs = { category_id: 1, name: "Canada", slug: "canada" }
        put "/v0/categories/world/canada", category: attrs.to_json
        last_response.status.must_equal 401
      end

      it "updates existing categories" do
        authorize "", "secret"
        attrs = { category_id: 1, name: "Canada", slug: "canada" }
        stub(category2).new? { false }
        mock(Models::Category).find_by_path!("world/canada", true) { category2 }
        mock(category2).update(attrs.stringify_keys!) { true }
        put "/v0/categories/world/canada", category: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal serialize(category2)
      end

      it "requires authentication to delete a category" do
        delete "/v0/categories/world/canada"
        last_response.status.must_equal 401
      end

      it "deletes a category" do
        authorize "", "secret"
        mock(Models::Category).find_by_path!("world/canada") { category2 }
        mock(category2).destroy { true }
        delete "/v0/categories/world/canada"
        last_response.status.must_equal 200
        last_response.body.must_equal ""
      end

      describe "recursive update" do
        before do
          category1.save
          category1.reload
          category2.save
        end

        it "adds facts to a category" do
          authorize "", "secret"
          attrs = { category_id: 1, name: "Canada", slug: "canada", facts: [
            { content: "Canada is big." },
          ]}
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.facts.count.must_equal 1
          category2.facts.first.content.must_equal "Canada is big."
        end

        it "keeps an existing fact" do
          authorize "", "secret"
          fact = Models::Fact.create content: "Canada is big.", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", facts: [
            { content: "Canada is big." },
          ]}
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.facts.count.must_equal 1
          category2.facts.first.id.must_equal fact.id
        end

        it "removes facts from a category" do
          authorize "", "secret"
          Models::Fact.create content: "Canada is big.", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", facts: [] }
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.facts.count.must_equal 0
        end

        it "doesn't remove facts from a category on a nil" do
          authorize "", "secret"
          Models::Fact.create content: "The world is big.", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", facts: nil }
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.facts.count.must_equal 1
        end

        it "adds a subcategory" do
          authorize "", "secret"
          attrs = { category_id: 1, name: "Canada", slug: "canada", categories: [
            { name: "Alberta", slug: "alberta" },
          ]}
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.categories.count.must_equal 1
          category2.categories.first.slug.must_equal "alberta"
        end

        it "keeps an existing subcategory" do
          authorize "", "secret"
          category = Models::Category.create name: "Alberta", slug: "alberta", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", categories: [
            { name: "Alberta", slug: "alberta" },
          ]}
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.categories.count.must_equal 1
          category2.categories.first.id.must_equal category.id
        end

        it "removes a subcategory" do
          authorize "", "secret"
          Models::Category.create name: "Alberta", slug: "alberta", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", categories: [] }
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.categories.count.must_equal 0
        end

        it "doesn't remove subcategories on a nil" do
          authorize "", "secret"
          Models::Category.create name: "Alberta", slug: "alberta", category_id: category2.id
          attrs = { category_id: 1, name: "Canada", slug: "canada", categories: nil }
          put "/v0/categories/world/canada", category: attrs.to_json
          last_response.status.must_equal 200
          category2.reload
          category2.categories.count.must_equal 1
        end

        it "allows a special top level category push" do
          authorize "", "secret"
          attrs = { categories: [] }
          put "/v0/categories", category: attrs.to_json
          last_response.status.must_equal 200
          last_response.body.must_equal ""
          Models::Category.count.must_equal 0
        end
      end

      private

      def serialize(obj)
        serialize_generic(Serializers::CategorySerializer, :api, obj)
      end
    end
  end
end
