module Facts
  class ApiAggregate < Grape::API
    helpers do
      include Facts::Api::Helpers
    end

    rescue_from Sequel::ValidationFailed do |e|
      Slides.log(:error, type: e.class.name, status: 422, id: request.id)
      rack_response(JSON.dump(e.errors.flatten), 422)
    end

    rescue_from *API_ERRORS do |e|
      Slides.log(:error, type: e.class.name, status: e.status, id: request.id)
      rack_response(JSON.dump({ error: e.message }), e.status)
    end

    rescue_from :all do |e|
      Slides.log(:error, type: e.class.name, message: e.message,
        id: request.id, backtrace: e.backtrace)
      rack_response(JSON.dump({ error: "Internal server error" }), 500)
    end

    mount Facts::Api::V0Categories
    mount Facts::Api::V0Facts
  end
end
