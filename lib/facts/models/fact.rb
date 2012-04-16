module Facts
  module Models
    class Fact < ActiveRecord::Base
      attr_accessible :category_id, :content
      belongs_to :category
      validates_presence_of :category, :content

      scope :random, order("RANDOM()")
      scope :search, lambda { |query|
        where 'facts.content ILIKE ?', "%#{query}%"
      }

      def content_html
        renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
          :fenced_code_blocks => true, :hard_wrap => true)
        renderer.render(content)
      end
    end
  end
end
