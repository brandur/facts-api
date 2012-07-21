module Facts
  module Api
    class V0Facts < Grape::API
      default_format :json
      error_format :json
      version 'v0', using: :header

      helpers do
        def serialize(fact)
          Serializers::FactSerializer.new(:v0).serialize(fact)
        end
      end

      resource :facts do
        # @todo: pagination
        get do
          serialize(Models::Fact.all)
        end

        get :latest do
          serialize(Models::Fact.order(:created_at).eager(:category).reverse.
            limit(50).all)
        end

        get :random do
          serialize(Models::Fact.order("RANDOM()".lit).eager(:category).
            limit(50).all)
        end

        get :search do
          results = Models::Fact.
            from(:facts, "to_tsquery('english', ?) query".lit(params[:q])).
            select_append("ts_rank_cd(tsv, query) AS rank".lit).
            where("query @@ tsv").order(:rank.desc).eager(:category).limit(50).all
          serialize(results)
        end

        post do
          authorized!
          require_params!(:fact)
          attrs = params[:fact].parse_json
          serialize(Models::Fact.create(attrs))
        end

        get ":id" do
          fact = Models::Fact.first(id: params[:id].to_i) || raise(NotFound)
          serialize(fact)
        end

        put ":id" do
          authorized!
          require_params!(:fact)
          fact = Models::Fact.first(id: params[:id].to_i) || raise(NotFound)
          attrs = params[:fact].parse_json
          fact.update(attrs)
          serialize(fact)
        end

        delete ":id" do
          authorized!
          fact = Models::Fact.first(id: params[:id].to_i) || raise(NotFound)
          fact.destroy
          {}.to_json
        end
      end
    end
  end
end
