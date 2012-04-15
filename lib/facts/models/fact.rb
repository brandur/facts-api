module Facts
  module Models
    class Fact < ActiveRecord::Base
      belongs_to :category
      validates_presence_of :category, :content

      scope :random, order("RAND()")
      scope :search, lambda { |query|
        where 'facts.id LIKE ? OR facts.content LIKE ?', "%#{query}%", "%#{query}%"
      }

      def content_html
        RDiscount.new(content).to_html
      end
    end
  end
end
