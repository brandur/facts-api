module Facts
  class ApiAggregate < Grape::API
    mount Facts::Api::V0Categories
    mount Facts::Api::V0Facts
  end
end
