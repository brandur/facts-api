module Facts
  module Serializers
    class CategorySerializer < Base
      def api(c)
        {
          :id          => c.id,
          :category_id => c.category_id,
          :name        => c.name,
          :slug        => c.slug,
          :categories  => nested_serializer.serialize(c.categories),
          :facts       => fact_serializer.serialize(c.facts),
        }
      end

      def category_nested(c)
        {
          :id          => c.id,
          :name        => c.name,
          :slug        => c.slug,
        }
      end

      def fact_nested(c)
        category_nested(c).merge! category_id: c.category_id
      end

      private

      def fact_serializer
        @@fact_serializer ||= FactSerializer.new(:nested)
      end

      def nested_serializer
        @@nested_serializer ||= CategorySerializer.new(:category_nested)
      end
    end
  end
end
