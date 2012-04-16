require "test_helper"

module Facts
  module Api
    describe "api v0 categories" do
      include Rack::Test::Methods

      let(:category1) { Models::Category.new(id: 1, name: "World", slug: "world") }
      let(:category2) { Models::Category.new(id: 2, name: "Canada", slug: "world/canada") }

      def app
        Facts::ApiAggregate
      end

      it "gets all" do
        mock(Models::Category).all { [category1, category2] }
        get "/v0/categories"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize([category1, category2])
      end

      it "gets top" do
        mock(Models::Category).top { [category1] }
        get "/v0/categories/top"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize([category1])
      end

      it "gets by slug" do
        mock(Models::Category).find_by_slug!("world/canada") { category1 }
        get "/v0/categories/world/canada"
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize(category1)
      end

      it "requires authentication to create a category" do
      end

      it "creates new categories" do
        attrs = { category_id: 1, name: "Canada", slug: "world/canada" }
        mock(Models::Category).create!(attrs.stringify_keys!) { category2 }
        post "/v0/categories", :category => attrs.to_json
        last_response.status.must_equal 201
        last_response.body.parse_json.must_equal serialize(category2)
      end

      it "requires authentication to update a category" do
      end

      it "updates existing categories" do
        attrs = { category_id: 1, name: "Canada", slug: "world/canada" }
        mock(Models::Category).find_by_slug!("world/canada") { category2 }
        mock(category2).update_attributes(attrs.stringify_keys!) { true }
        put "/v0/categories/world/canada", :category => attrs.to_json
        last_response.status.must_equal 200
        last_response.body.parse_json.must_equal serialize(category2)
      end

      it "requires authentication to delete a category" do
      end

      it "deletes a category" do
        mock(Models::Category).find_by_slug!("world/canada") { category2 }
        mock(category2).destroy { true }
        delete "/v0/categories/world/canada"
        last_response.status.must_equal 200
        last_response.body.must_equal ""
      end

      private

      def serialize(obj)
        serialize_generic(Serializers::CategorySerializer, :api, obj)
      end
    end
  end
end
