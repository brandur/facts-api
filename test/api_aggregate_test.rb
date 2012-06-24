require "test_helper"

module Facts
  module Api
    describe "api general" do
      include Rack::Test::Methods

      def app
        Facts::ApiAggregate
      end

      it "rescues from errors" do
        mock(Models::Category).find_by_path!("500") { raise "ERR-OR!" }
        get "/v0/categories/500"
        last_response.status.must_equal 500
        last_json.must_equal({ "error" => "Internal server error" })
      end
    end
  end
end
