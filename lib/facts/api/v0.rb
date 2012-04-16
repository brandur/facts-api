module Facts
  module Api
    class V0 < Grape::API
      default_format :json
      error_format :json

      version 'v0', :using => :path

      helpers do
        def authenticate!
        end

        def require_params!(*keys)
          keys.each do |key|
            error!("Require parameter: #{key}", 422) unless params[key]
          end
        end

        def serializer
          @@serializer ||= Serializers::FactSerializer.new(:api)
        end

        def serialize(obj)
          serializer.serialize(obj)
        end
      end

      resource :facts do
        get do
          serialize(Models::Fact.all)
        end

        get :latest do
        end

        post do
          authenticate!
          require_params!(:fact)
          attrs = params[:fact].parse_json
          serialize(Models::Fact.create!(attrs))
        end

        get ":id" do
          serialize(Models::Fact.find!(params[:id]))
        end

        put ":id" do
          authenticate!
          require_params!(:fact)
          fact = Models::Fact.find!(params[:id])
          attrs = params[:fact].parse_json
          fact.update_attributes(attrs)
          serialize(fact)
        end

        delete ":id" do
          authenticate!
          fact = Models::Fact.find!(params[:id])
          fact.destroy
          ""
        end
      end
    end
  end
end
