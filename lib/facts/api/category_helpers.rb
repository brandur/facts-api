module Facts
  module Api
    module CategoryHelpers
      @@serializer = Serializers::CategorySerializer.new(:v0)

      def serialize(obj)
        @@serializer.serialize(obj).to_json
      end

      def update_categories(categories)
        categories_not_updated =
          Set.new(Models::Category.select(:id).all.map(&:id))
        categories.each do |attrs|
          facts = attrs.delete("facts")
          category = Models::Category.first(slug: attrs["slug"])
          unless category
            category = Models::Category.create(attrs)
          else
            category.update(attrs)
            categories_not_updated.delete(category.id)
          end
          update_facts(category, facts) if facts
        end

        # delete any facts that aren't supposed to be here anymore
        if categories_not_updated.count > 0
          Slides.log :destroying, categories: categories_not_updated.to_a
          Models::Category.filter(id: categories_not_updated.to_a).destroy
        end
      end

      def update_facts(category, facts)
        facts_not_updated = Hash[*category.facts.map { |f| [f.id, f]}.flatten]
        facts.each do |attrs|
          fact =
            category.facts.select { |f| f.content == attrs["content"] }.first
          unless fact
            Models::Fact.create(attrs.merge(category: category))
          else
            facts_not_updated.delete(fact.id)
          end
        end

        # delete any facts that aren't supposed to be here anymore
        if facts_not_updated.count > 0
          Slides.log :destroying, facts: facts_not_updated.keys
          facts_not_updated.each { |id, fact| fact.destroy }
        end

        category.reload
      end
    end
  end
end
