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

      # @TODO: complete rewrite
      def self.find_by_path!(path)
        slugs = path.split(%r{/})
        query = eager(:ancestors, descendants: :facts).filter(slug: slugs.first)
        slugs[1..slugs.count].each { |s| query = query.or(slug: s) }

        category = nil
        categories = query.all
        slugs.each do |slug|
          category = unless category
            # top-level, so first part of slug must be unique
            categories.detect { |c| c.slug == slug }
          else
            categories.detect { |c| c.slug == slug && c.category_id == category.id }
          end
          raise NotFound unless category
        end
        category
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
