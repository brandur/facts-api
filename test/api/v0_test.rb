require "test_helper"

describe Facts::Api::V0 do
  include Rack::Test::Methods

  def app
    Facts::Api::V0
  end

  describe "facts" do
    it "gets latest" do
      get "/v0/facts/latest"
      last_response.status.must_equal 200
      last_response.body.must_equal ({ message: "woot woot!" }.to_json)
    end
  end
end
