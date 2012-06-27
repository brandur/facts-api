module Facts
  module Models
    class Fact < Sequel::Model
      plugin :timestamps
      plugin :validation_helpers

      #set_allowed_columns :category_id, :content

      many_to_one :category

      def self.find!(id)
        first(id: id) || raise(NotFound)
      end

      def self.ordered
        order(:created_at)
      end

      def self.random
        order("RANDOM()".lit)
      end

      def self.search(query)
        filter('facts.content ILIKE ?', "%#{query}%")
      end

      def content_html
        renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
          :fenced_code_blocks => true, :hard_wrap => true)
        renderer.render(content)
      end

      def validate
        super
        validates_presence [:category_id, :content]
      end
    end
  end
end
