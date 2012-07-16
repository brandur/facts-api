module Facts
  module Models
    class Category < Sequel::Model
      plugin :rcte_tree, key: :category_id
      plugin :timestamps
      plugin :validation_helpers

      #set_allowed_columns :category_id, :name, :slug

      one_to_many :facts

      def self.find!(id)
        first(id: id) || raise(NotFound)
      end

      def self.ordered
        order(:name)
      end

      def self.search(query)
        filter(:name.qualify(:categories).ilike("%#{query}%"))
      end

      def self.top
        eager(descendants: :facts).filter(category_id: nil)
      end

      def self.find_by_path!(path, eager=false)
        slugs = path.split(%r{/}).reverse
        query = eager ?
          eager(:ancestors, descendants: :facts) :
          eager(:ancestors)
        query = query.filter(slug: slugs.first)

        categories = query.all
        leaf = nil

        categories.each do |category|
          leaf = category
          slugs.each do |slug|
            if category.slug == slug
              category = category.parent
            else
              category = nil
              break
            end
          end
          break if category
        end
        raise NotFound unless leaf
        leaf
      end

      def category
        parent
      end

      def categories
        children
      end

      def path
        (parent ? "#{parent.path}/" : "") + slug
      end

      def to_param
        path
      end

      def validate
        super
        validates_presence [:name, :slug]
        validates_format %r{^[a-z0-9][a-z0-9-]*[a-z0-9]$}, [:slug]
        validates_unique [:slug] { |ds| ds.filter(category_id: category_id) }
      end
    end
  end
end
