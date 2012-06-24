module Facts
  module Api
    class V0Categories < Grape::API
      default_format :json
      error_format :json
      version 'v0', using: :path

      helpers do
        include CategoryHelpers
      end

      resource :categories do
        get do
          serialize(Models::Category.all)
        end

        get :top do
          serialize(Models::Category.top)
        end

        post do
          authorized!
          require_params!(:category)
          attrs = params[:category].parse_json
          category = Models::Category.create!(attrs)
          Models::Category.transaction do
            stats = update_category(category, attrs)
            log(:category_created, stats)
          end
          serialize(category)
        end

        get "*path" do
          serialize(Models::Category.find_by_path!(params[:path]))
        end

        put "*path" do
          authorized!
          require_params!(:category)
          attrs = params[:category].parse_json
          category = Models::Category.find_by_path!(params[:path])
          Models::Category.transaction do
            stats = update_category(category, attrs)
            log(:category_updated, stats)
          end
          serialize(category)
        end

        # special top level sync
        put do
          authorized!
          require_params!(:category)
          attrs = params[:category].parse_json
          Models::Category.transaction do
            stats = update_categories(CategoryHelpers::TopCategory,
              attrs["categories"])
            log(:category_updated, stats)
          end
          ""
        end

        delete "*path" do
          authorized!
          category = Models::Category.find_by_path!(params[:path])
          category.destroy
          ""
        end
      end
    end
  end
end
