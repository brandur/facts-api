module Facts
  module Serializers
    class CategorySerializer < Base
      def v0(c)
        {
          id:        c.id,
          name:      c.name,
          slug:      c.slug,
          facts:     c.facts.map { |f| {
            id:      f.id,
            content: f.content,
          } }
        }
      end
    end
  end
end
