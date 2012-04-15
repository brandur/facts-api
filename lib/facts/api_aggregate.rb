module Facts
  class ApiAggregate < Grape::API
    mount Facts::Api::V0
  end
end
