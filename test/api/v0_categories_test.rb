require "test_helper"

module Facts
  module Api
    describe "api v0 categories" do
      include Rack::Test::Methods

      before do
        ENV["FACTS_HTTP_API_KEY"] = "secret"
      end

      let(:category) { Models::Category.new(id: 1, name: "Canada", slug: "canada") }

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        mock(Models::Category).all { [category] }
        get "/categories"
        last_response.status.must_equal 200
        last_json.must_equal serialize([category])
      end

      it "gets by slug" do
        category.save
        get "/categories/canada"
        last_response.status.must_equal 200
        last_json.must_equal serialize(category)
      end

      it "renders a 404" do
        get "/categories/does-not-exist"
        last_response.status.must_equal 404
        last_json.must_equal({ "error" => "Not found" })
      end

      it "performs top level sync" do
        category.save

        authorize "", "secret"
        attrs = [{ name: "World", slug: "world", facts: [
          { content: "The world is very big." }
        ] }]
        put "/categories", categories: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal({})

        Models::Category.count.must_equal 1
        Models::Fact.count.must_equal 1
      end

      it "requires authentication to create a category" do
        attrs = { category_id: 1, name: "Canada", slug: "canada" }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 401
      end

      it "creates new categories" do
        authorize "", "secret"
        attrs = { name: "Canada", slug: "canada" }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 201
        last_json.must_equal(stringify_keys({ id: last_json["id"], name: "Canada",
          slug: "canada", facts: [] }))
      end

      it "creates new categories with facts" do
        authorize "", "secret"
        attrs = { name: "Canada", slug: "canada", facts: [
          { content: "Canada is very big." }
        ] }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 201
        last_json.must_equal(stringify_keys({ id: last_json["id"], name: "Canada",
          slug: "canada", facts: [
            id: last_json["facts"][0]["id"], content: "Canada is very big."
          ] }))
      end

      it "requires authentication to update a category" do
        attrs = { name: "Canada", slug: "canada" }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 401
      end

      it "updates existing categories" do
        category.save
        authorize "", "secret"
        attrs = { name: "Canada", slug: "canada" }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal(stringify_keys({ id: last_json["id"], name: "Canada",
          slug: "canada", facts: [] }))
      end

      it "updates existing categories with facts" do
        category.save
        Models::Fact.create(category: category, content: "Canada is big.")
        authorize "", "secret"
        attrs = { name: "Canada", slug: "canada", facts: [
          { content: "Canada is very big." }
        ] }
        put "/categories/canada", category: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal(stringify_keys({ id: last_json["id"], name: "Canada",
          slug: "canada", facts: [
            id: last_json["facts"][0]["id"], content: "Canada is very big."
          ] }))
      end

      it "requires authentication to delete a category" do
        delete "/categories/canada"
        last_response.status.must_equal 401
      end

      it "deletes a category" do
        category.save
        authorize "", "secret"
        delete "/categories/canada"
        last_response.status.must_equal 200
        last_json.must_equal({})
      end

      private

      def serialize(obj)
        serialize_generic(Serializers::CategorySerializer, :api, obj)
      end
    end
  end
end
