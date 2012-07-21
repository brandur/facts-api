module Facts
  module Serializers
    class FactSerializer < Base
      def v0(f)
        {
          id:         f.id,
          content:    f.content,
          created_at: f.created_at,
          category:   {
            id:       f.category.id,
            name:     f.category.name,
            slug:     f.category.slug,
          }
        }
      end
    end
  end
end
