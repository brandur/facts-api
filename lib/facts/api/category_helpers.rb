module Facts
  module Api
    module CategoryHelpers
      @@serializer = Serializers::CategorySerializer.new(:api)

      class TopCategory
        def children
          Models::Category.top
        end
      end

      def log_stats(stats)
        log(:category_stats, stats)
      end

      def merge_stats!(stats1, stats2 = {})
        stats1.merge!(stats2) do |key, val1, val2|
          val1 + val2
        end
      end

      def serialize(obj)
        @@serializer.serialize(obj)
      end

      def update_categories(category, category_attrs_arr)
        stats = { categories_created: 0 }
        categories = category.children
        categories_not_updated = Hash[*categories.map { |c| [c.id, c]}.flatten]
        category_attrs_arr.each do |category_attrs|
          new_category = categories.
            select { |c| c.slug == category_attrs["slug"] }.first
          unless new_category
            new_category = Models::Category.create(
              #parent: !category.kind_of?(TopCategory) ? category : nil,
              name: category_attrs["name"], slug: category_attrs["slug"])
            #new_category = Models::Category.new
            #new_category.parent = !category.kind_of?(TopCategory) ? category : nil
            #new_category.set_fields(category_attrs, [:name, :slug], missing: :skip)
            #new_category.save
puts "created #{new_category.slug}; parent = #{new_category.parent ? new_category.parent.name : nil}"
            merge_stats!(stats, categories_created: 1)
          end

          sub_stats = update_category(new_category, category_attrs)
          merge_stats!(stats, sub_stats)
          categories_not_updated.delete(new_category.id)
        end

        # delete any categories that aren't supposed to be here anymore
        categories_not_updated.each { |id, category| category.destroy }
        merge_stats!(stats, categories_destroyed: categories_not_updated.count)
        stats
      end

      def update_category(category, category_attrs)
puts "updating category = #{category_attrs["name"]}"
        stats = { categories_updated: 0 }

        category_attrs_arr = category_attrs.delete("categories")
        fact_attrs_arr = category_attrs.delete("facts")

        # don't bother updating attributes if it looks like this is a
        # category that we've just created
        unless category.new?
          category.update(category_attrs)
          merge_stats!(stats, categories_updated: 1)
        end

        if category_attrs_arr
puts "updating subcategories for #{category.name}"
          sub_stats = update_categories(category, category_attrs_arr) 
          merge_stats!(stats, sub_stats)
        end

        if fact_attrs_arr
puts "updating facts for #{category.name}"
          sub_stats = update_facts(category, fact_attrs_arr) 
          merge_stats!(stats, sub_stats)
        end

        stats
      end

      def update_facts(category, fact_attrs_arr)
        stats = { facts_created: 0 }
        facts = category.facts
        facts_not_updated = Hash[*facts.map { |f| [f.id, f]}.flatten]
        fact_attrs_arr.each do |fact_attrs|
          fact = facts.select { |f| f.content == fact_attrs["content"] }.first
          unless fact
            Models::Fact.create(fact_attrs.merge(category: category))
            merge_stats!(stats, facts_created: 1)
          else
            facts_not_updated.delete(fact.id)
          end
        end

        # delete any facts that aren't supposed to be here anymore
        facts_not_updated.each { |id, fact| fact.destroy }
        merge_stats!(stats, facts_destroyed: facts_not_updated.count)
      end
    end
  end
end
