module Facts
  module Serializers
    class FactSerializer < Base
      def api(f)
        {
          :id         => f.id,
          :content    => f.content,
          :created_at => f.created_at,
          :category   => category_serializer.serialize(f.category),
        }
      end

      def category_nested(f)
        {
          :id      => f.id,
          :content => f.content,
        }
      end

      private

      def category_serializer
        @@category_serializer ||= CategorySerializer.new(:fact_nested)
      end
    end
  end
end
