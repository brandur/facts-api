module Facts
  module Api
    class V0Categories < Grape::API
      default_format :json
      error_format :json
      version 'v0', using: :header

      helpers do
        include CategoryHelpers

        def serialize(category)
          Serializers::CategorySerializer.new(:v0).serialize(category)
        end
      end

      resource :categories do
        # @todo: pagination
        get do
          serialize(Models::Category.all)
        end

        get :search do
          results = Models::Category.
            from(:categories, "to_tsquery('english', ?) query".lit(params[:q])).
            select_append("ts_rank_cd(tsv, query) AS rank".lit).
            where("query @@ tsv").order(:rank.desc).eager(:facts).limit(50).all
          serialize(results)
        end

        # special top level sync
        put do
          authorized!
          require_params!(:categories)
          attrs = params[:categories].parse_json
          DB.transaction do
            update_categories(attrs)
          end
          {}.to_json
        end

        get ":slug" do
          category = Models::Category.eager(:facts).
            first(slug: params[:slug]) || raise(NotFound)
          serialize(category)
        end

        # idempotent endpoint for both category creation and update
        put ":slug" do
          authorized!
          require_params!(:category)
          attrs = params[:category].parse_json
          category = nil
          DB.transaction do
            facts = attrs.delete("facts")
            if category = Models::Category.eager(:facts).
              first(slug: params[:slug])
                category.update(attrs)
            else
              category = Models::Category.create(attrs)
              status(201)
            end
            update_facts(category, facts) if facts
          end
          serialize(category)
        end

        delete ":slug" do
          authorized!
          category = Models::Category.first(slug: params[:slug]) ||
            raise(NotFound)
          category.destroy
          {}.to_json
        end
      end
    end
  end
end
