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

        def update_categories(category, category_attrs_arr)
          categories_not_updated = Hash[*category.categories.map{ |c| [c.id, c]}.flatten]
          category_attrs_arr.each do |category_attrs|
            new_category = category.categories.find_by_slug(category_attrs["slug"])
            if new_category
              update_category(new_category, category_attrs)
            else
              category.categories.create!(category_attrs)
            end
          end

          # delete any categories that aren't supposed to be here anymore
          categories_not_updated.each{ |id, category| category.destroy }
        end

        def update_category(category, category_attrs)
          category_attrs_arr = category_attrs.delete("categories")
          update_categories(category, category_attrs_arr) if category_attrs_arr

          fact_attrs_arr = category_attrs.delete("facts")
          update_facts(category, fact_attrs_arr) if fact_attrs_arr

          category.update_attributes(category_attrs)
        end

        def update_facts(category, fact_attrs_arr)
          facts_not_updated = Hash[*category.facts.map{ |f| [f.id, f]}.flatten]
          fact_attrs_arr.each do |fact_attrs|
            fact = category.facts.find_by_content(fact_attrs["content"])
            if fact
              fact.update_attributes(fact_attrs)
              facts_note_updated.delete(fact.id)
            else
              category.facts.create!(fact_attrs)
            end
          end

          # delete any facts that aren't supposed to be here anymore
          facts_not_updated.each{ |id, fact| fact.destroy }
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

        get "*path" do
          serialize(Models::Category.find_by_path!(params[:path]))
        end

        put "*path" do
          authenticate!
          require_params!(:category)
          category = Models::Category.find_by_path!(params[:path])
          attrs = params[:category].parse_json
          Models::Category.transaction do
            update_category(category, attrs)
          end
          serialize(category)
        end

        delete "*path" do
          authenticate!
          category = Models::Category.find_by_path!(params[:path])
          category.destroy
          ""
        end
      end
    end
  end
end
