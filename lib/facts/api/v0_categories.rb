module Facts
  module Api
    class V0Categories < Grape::API
      default_format :json
      helpers { include Helpers }
      error_format :json
      rescue_from :all
      version 'v0', :using => :path

      helpers do
        @@serializer = Serializers::CategorySerializer.new(:api)

        class TopCategory
          def self.categories
            Models::Category.top
          end
        end

        def merge_stats(stats1, stats2 = {})
          stats1.merge(stats2) do |key, val1, val2|
            val1 + val2
          end
        end

        def serialize(obj)
          @@serializer.serialize(obj)
        end

        def update_categories(category, category_attrs_arr)
          stats = { categories_created: 0 }
          categories_not_updated = Hash[*category.categories.map{ |c| [c.id, c]}.flatten]
          category_attrs_arr.each do |category_attrs|
            new_category = category.categories.find_by_slug(category_attrs["slug"], include: :facts)
            unless new_category
              new_category = category.categories.create!(category_attrs)
              merge_stats(stats, categories_created: 2)
            end

            sub_stats = update_category(new_category, category_attrs)
            merge_stats(stats, sub_stats)
            categories_not_updated.delete(new_category.id)
          end

          # delete any categories that aren't supposed to be here anymore
          categories_not_updated.each{ |id, category| category.destroy }
          merge_stats(stats, categories_deleted: categories_not_updated.count)
          stats
        end

        def update_category(category, category_attrs)
          stats = { categories_updated: 0 }
          # don't bother updating attributes if it looks like this is a
          # caegory that we've just created
          unless category.new_record?
            category.update_attributes(category_attrs) 
            merge_stats(stats, categories_updated: 1)
          end

          category_attrs_arr = category_attrs.delete("categories")
          if category_attrs_arr
            sub_stats = update_categories(category, category_attrs_arr) 
            merge_stats(stats, sub_stats)
          end

          fact_attrs_arr = category_attrs.delete("facts")
          if fact_attrs_arr
            sub_stats = update_facts(category, fact_attrs_arr) 
            merge_stats(stats, sub_stats)
          end

          stats
        end

        def update_facts(category, fact_attrs_arr)
          stats = { facts_created: 0 }
          facts_not_updated = Hash[*category.facts.map{ |f| [f.id, f]}.flatten]
          fact_attrs_arr.each do |fact_attrs|
            fact = category.facts.find_by_content(fact_attrs["content"])
            if fact
              # don't actually update, because nothing has changed
              #fact.update_attributes(fact_attrs)
              facts_not_updated.delete(fact.id)
            else
              category.facts.create!(fact_attrs)
              merge_stats(stats, facts_created: 1)
            end
          end

          # delete any facts that aren't supposed to be here anymore
          facts_not_updated.each{ |id, fact| fact.destroy }
          merge_stats(stats, facts_destroyed: facts_not_updated.count)
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
          authenticate!
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
          authenticate!
          require_params!(:category)
          attrs = params[:category].parse_json
          Models::Category.transaction do
            stats = update_categories(TopCategory, attrs["categories"])
            log(:category_updated, stats)
          end
          ""
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
