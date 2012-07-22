require "test_helper"

module Facts
  module Api
    describe "api v0 facts" do
      include Rack::Test::Methods

      before do
        ENV["FACTS_HTTP_API_KEY"] = "secret"

        @category = Models::Category.create(name: "World", slug: "world")
        @fact1    = Models::Fact.create(category: @category,
          content: "The world is big.")
        @fact2    = Models::Fact.create(category: @category,
          content: "The world is round.")
      end

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        get "/facts"
        last_response.status.must_equal 200
        last_json.must_equal serialize([@fact1, @fact2])
      end

      it "gets latest" do
        get "/facts/latest"
        last_response.status.must_equal 200
        last_json.must_equal serialize([@fact2, @fact1])
      end

      it "gets random" do
        get "/facts/random"
        last_response.status.must_equal 200
        last_json.must_include serialize(@fact1)
        last_json.must_include serialize(@fact2)
      end

      it "gets search" do
        get "/facts/search", q: "worldly"
        last_response.status.must_equal 200
        last_json.must_equal serialize([@fact1, @fact2])
      end

      it "gets by id" do
        get "/facts/#{@fact1.id}"
        last_response.status.must_equal 200
        last_json.must_equal serialize(@fact1)
      end

      it "renders a 404" do
        get "/facts/7777"
        last_response.status.must_equal 404
        last_json.must_equal({ "error" => "Not found" })
      end

      it "is able to handle a non-integer" do
        get "/facts/may-error-the-database"
        last_response.status.must_equal 404
        last_json.must_equal({ "error" => "Not found" })
      end

      it "requires authentication to create a fact" do
        attrs = { category_id: @category.id, content: "The world is big." }
        post "/facts", { fact: attrs.to_json }
        last_response.status.must_equal 401
      end

      it "creates new facts" do
        authorize "", "secret"
        attrs = { category_id: @category.id, content: "The world is big." }
        post "/facts", { fact: attrs.to_json }
        last_response.status.must_equal 201
        last_json.must_equal(stringify_keys({ id: last_json["id"],
          content: "The world is big.", created_at: last_json["created_at"],
          category: { id: last_json["category"]["id"], name: "World", slug: "world" }
        }))
      end

      it "requires authentication to update a fact" do
        attrs = { category_id: @category.id, content: "The world is very big." }
        put "/facts/#{@fact1.id}", fact: attrs.to_json
        last_response.status.must_equal 401
      end

      it "updates existing facts" do
        authorize "", "secret"
        attrs = { category_id: @category.id, content: "The world is very big." }
        put "/facts/#{@fact1.id}", fact: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal(stringify_keys({ id: last_json["id"],
          content: "The world is very big.", created_at: last_json["created_at"],
          category: { id: last_json["category"]["id"], name: "World", slug: "world" }
        }))
      end

      it "requires authentication to delete a fact" do
        delete "/facts/#{@fact1.id}"
        last_response.status.must_equal 401
      end

      it "deletes a fact" do
        authorize "", "secret"
        delete "/facts/#{@fact1.id}"
        last_response.status.must_equal 200
        last_json.must_equal({})
      end

      private

      def serialize(obj)
        serialize_generic(Serializers::FactSerializer, :v0, obj)
      end
    end
  end
end
