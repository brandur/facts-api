module Facts
  module Models
    class Category < ActiveRecord::Base
      attr_accessible :category_id, :name, :slug
      belongs_to :category
      has_many :categories, :dependent => :destroy

      has_many :facts

      validates :name, presence: true
      validates :slug, presence: true, format: %r{^[a-z0-9][a-z0-9-]*[a-z0-9]$}
      validates_uniqueness_of :slug, scope: :category_id

      default_scope :order => :name
      scope :top, where(:category_id => nil)
      scope :search, lambda { |query|
        where 'categories.name ILIKE ?', "%#{query}%"
      }

      def self.find_by_path(path)
        slugs = path.split(%r{/}).reverse
        categories = arel_table
        query = categories.where(categories[:slug].eq(slugs.shift))
        slugs.each_with_index do |slug, i|
          parent = arel_table.alias("categories#{i}")
          query = query.join(parent).on(categories[:category_id].eq(parent[:id])).
            where(parent[:slug].eq(slug))
          categories = parent
        end
        query = query.project(Arel.sql("categories.*")).take(1)
        sql = query.to_sql
        find_by_sql(sql).first
      end

      def self.find_by_path!(path)
        find_by_path(path) or raise ActiveRecord::RecordNotFound
      end

      def path
        (category ? "#{category.path}/" : "") + slug
      end

      def to_param
        path
      end
    end
  end
end
