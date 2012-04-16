module Facts
  module Api
    class V0Categories < Grape::API
      default_format :json
      helpers { include Helpers }
      error_format :json
      version 'v0', :using => :path

      helpers do
        @@serializer = Serializers::CategorySerializer.new(:api)

        def serialize(obj)
          @@serializer.serialize(obj)
        end
      end

      resource :categories do
        get do
          serialize(Models::Category.all)
        end

        get :top do
          serialize(Models::Category.top)
        end

        post do
          authenticate!
          require_params!(:category)
          attrs = params[:category].parse_json
          serialize(Models::Category.create!(attrs))
        end

        get "*slug" do
          serialize(Models::Category.find_by_slug!(params[:slug]))
        end

        put "*slug" do
          authenticate!
          require_params!(:category)
          category = Models::Category.find_by_slug!(params[:slug])
          attrs = params[:category].parse_json
          category.update_attributes(attrs)
          serialize(category)
        end

        delete "*slug" do
          authenticate!
          category = Models::Category.find_by_slug!(params[:slug])
          category.destroy
          ""
        end
      end
    end
  end
end
