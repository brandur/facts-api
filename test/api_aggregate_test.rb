require "test_helper"

module Facts
  module Api
    describe "api general" do
      include Rack::Test::Methods

      def app
        Facts::ApiAggregate
      end

      it "rescues from errors" do
      end
    end
  end
end
