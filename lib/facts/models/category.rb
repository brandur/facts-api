module Facts
  module Models
    class Category < ActiveRecord::Base
      attr_accessible :category_id, :name, :slug
      belongs_to :category
      has_many :categories

      has_many :facts

      validates_presence_of :name, :slug
      validates_uniqueness_of :slug

      default_scope :order => :name
      scope :top, where(:category_id => nil)
      scope :search, lambda { |query|
        where 'categories.name ILIKE ?', "%#{query}%"
      }
    end
  end
end
