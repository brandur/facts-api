module Facts
  module Api
    module CategoryHelpers
      @@serializer = Serializers::CategorySerializer.new(:api)

      def serialize(obj)
        @@serializer.serialize(obj).to_json
      end

      def update_facts(category, facts)
        facts_not_updated = Hash[*category.facts.map { |f| [f.id, f]}.flatten]
        facts.each do |attrs|
          fact = category.facts.select { |f| f.content == fact["content"] }.first
          unless fact
            Models::Fact.create(attrs.merge(category: category))
          else
            facts_not_updated.delete(fact.id)
          end
        end

        # delete any facts that aren't supposed to be here anymore
        facts_not_updated.each { |id, fact| fact.destroy }
      end
    end
  end
end
