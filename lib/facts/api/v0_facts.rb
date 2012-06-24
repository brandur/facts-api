module Facts
  module Api
    class V0Facts < Grape::API
      default_format :json
      error_format :json
      version 'v0', :using => :path

      helpers do
        include FactHelpers
      end

      resource :facts do
        get do
          serialize(Models::Fact.all)
        end

        get :latest do
          serialize(Models::Fact.ordered.limit(50))
        end

        get :random do
          serialize(Models::Fact.random.limit(50))
        end

        post do
          authorized!
          require_params!(:fact)
          attrs = params[:fact].parse_json
          serialize(Models::Fact.create!(attrs))
        end

        get ":id" do
          serialize(Models::Fact.find_by_id!(params[:id]))
        end

        put ":id" do
          authorized!
          require_params!(:fact)
          fact = Models::Fact.find!(params[:id])
          attrs = params[:fact].parse_json
          fact.update_attributes(attrs)
          serialize(fact)
        end

        delete ":id" do
          authorized!
          fact = Models::Fact.find!(params[:id])
          fact.destroy
          ""
        end
      end
    end
  end
end
