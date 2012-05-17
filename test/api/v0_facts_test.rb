require "test_helper"

module Facts
  module Api
    describe "api v0 facts" do
      include Rack::Test::Methods

      before do
        ENV["FACTS_HTTP_API_KEY"] = "secret"
      end

      let(:fact1) { Models::Fact.new(id: 1, content: "The world is big.") }
      let(:fact2) { Models::Fact.new(id: 2, content: "The world is round.") }

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        mock(Models::Fact).all { [fact1, fact2] }
        get "/v0/facts"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize([fact1, fact2])
      end

      it "gets latest" do
        mock(Models::Fact).ordered.mock!.limit(50) { [fact1, fact2] }
        get "/v0/facts/latest"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize([fact1, fact2])
      end

      it "gets latest" do
        mock(Models::Fact).random.mock!.limit(50) { [fact1, fact2] }
        get "/v0/facts/random"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize([fact1, fact2])
      end

      it "gets by id" do
        mock(Models::Fact).find!("1") { fact1 }
        get "/v0/facts/1"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize(fact1)
      end

      it "requires authentication to create a fact" do
        attrs = { category_id: 1, content: "The world is big." }
        post "/v0/facts", { fact: attrs.to_json }
        last_response.status.must_equal 401
      end

      it "creates new facts" do
        authorize "", "secret"
        attrs = { category_id: 1, content: "The world is big." }
        mock(Models::Fact).create!(attrs.stringify_keys!) { fact1 }
        post "/v0/facts", { fact: attrs.to_json }
        last_response.status.must_equal 201
        last_response.body.parse_json.must_equal serialize(fact1)
      end

      it "requires authentication to update a fact" do
        attrs = { content: "The world is very big." }
        put "/v0/facts/1", fact: attrs.to_json
        last_response.status.must_equal 401
      end

      it "updates existing facts" do
        authorize "", "secret"
        attrs = { content: "The world is very big." }
        mock(Models::Fact).find!("1") { fact1 }
        mock(fact1).update_attributes(attrs.stringify_keys!) { true }
        put "/v0/facts/1", fact: attrs.to_json
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize(fact1)
      end

      it "requires authentication to delete a fact" do
        delete "/v0/facts/1"
        last_response.status.must_equal 401
      end

      it "deletes a fact" do
        authorize "", "secret"
        mock(Models::Fact).find!("1") { fact1 }
        mock(fact1).destroy { true }
        delete "/v0/facts/1"
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
