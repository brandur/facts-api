module Facts
  module Serializers
    class CategorySerializer < Base
      def api(c)
        {
          id:    c.id,
          name:  c.name,
          slug:  c.slug,
          facts: fact_serializer.serialize(c.facts),
        }
      end

      def nested(c)
        {
          id:   c.id,
          name: c.name,
          slug: c.slug,
        }
      end

      private

      def fact_serializer
        @@fact_serializer ||= FactSerializer.new(:nested)
      end
    end
  end
end
