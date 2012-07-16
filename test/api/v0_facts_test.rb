require "test_helper"

module Facts
  module Api
    describe "api v0 facts" do
      include Rack::Test::Methods

      before do
        ENV["FACTS_HTTP_API_KEY"] = "secret"
      end

      let(:category) { Models::Category.new(id: 1, name: "World", slug: "world") }
      let(:fact1) { Models::Fact.new(id: 1, category: category, content: "The world is big.") }
      let(:fact2) { Models::Fact.new(id: 2, category: category, content: "The world is round.") }

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        mock(Models::Fact).all { [fact1, fact2] }
        get "/facts"
        last_response.status.must_equal 200
        last_json.must_equal serialize([fact1, fact2])
      end

      it "gets latest" do
        mock(Models::Fact).ordered.mock!.limit(50) { [fact1, fact2] }
        get "/facts/latest"
        last_response.status.must_equal 200
        last_json.must_equal serialize([fact1, fact2])
      end

      it "gets by id" do
        category.save
        fact1.save
        get "/facts/#{fact1.id}"
        last_response.status.must_equal 200
        last_json.must_equal serialize(fact1)
      end

      it "renders a 404" do
        get "/facts/7777"
        last_response.status.must_equal 404
        last_json.must_equal({ "error" => "Not found" })
      end

      it "requires authentication to create a fact" do
        category.save
        attrs = { category_id: category.id, content: "The world is big." }
        post "/facts", { fact: attrs.to_json }
        last_response.status.must_equal 401
      end

      it "creates new facts" do
        category.save
        authorize "", "secret"
        attrs = { category_id: category.id, content: "The world is big." }
        post "/facts", { fact: attrs.to_json }
        last_response.status.must_equal 201
        last_json.must_equal(stringify_keys({ id: last_json["id"], content: "The world is big.",
          created_at: last_json["created_at"],
          category: { id: last_json["category"]["id"], name: "World", slug: "world" }
        }))
      end

      it "requires authentication to update a fact" do
        category.save
        fact1.save
        attrs = { category_id: category.id, content: "The world is very big." }
        put "/facts/#{fact1.id}", fact: attrs.to_json
        last_response.status.must_equal 401
      end

      it "updates existing facts" do
        category.save
        fact1.save
        authorize "", "secret"
        attrs = { category_id: category.id, content: "The world is very big." }
        put "/facts/#{fact1.id}", fact: attrs.to_json
        last_response.status.must_equal 200
        last_json.must_equal(stringify_keys({ id: last_json["id"], content: "The world is very big.",
          created_at: last_json["created_at"],
          category: { id: last_json["category"]["id"], name: "World", slug: "world" }
        }))
      end

      it "requires authentication to delete a fact" do
        category.save
        fact1.save
        delete "/facts/#{fact1.id}"
        last_response.status.must_equal 401
      end

      it "deletes a fact" do
        category.save
        fact1.save
        authorize "", "secret"
        delete "/facts/#{fact1.id}"
        last_response.status.must_equal 200
        last_response.body.must_equal ""
      end

      private

      def serialize(obj)
        serialize_generic(Serializers::FactSerializer, :api, obj)
      end
    end
  end
end
