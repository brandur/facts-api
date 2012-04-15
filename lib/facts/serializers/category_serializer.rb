module Facts
  module Serializers
    class CategorySerializer < Base
      def api(c)
        {
          :id          => c.id,
          :category_id => c.category_id,
          :name        => c.name,
          :slug        => c.slug,
          :facts       => fact_serializer.serialize(c.facts)
        }
      end

      def fact_nested(c)
        {
          :id          => c.id,
          :category_id => c.category_id,
          :name        => c.name,
          :slug        => c.slug,
        }
      end

      private

      def fact_serializer
        @@fact_serializer ||= FactSerializer.new(:category_nested)
      end
    end
  end
end
