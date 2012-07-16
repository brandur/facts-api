module Facts
  module Models
    class Category < Sequel::Model
      one_to_many :facts
      plugin :timestamps
      plugin :validation_helpers
      #set_allowed_columns :name, :slug

      def self.ordered
        order(:name)
      end

      def self.search(query)
        filter(:name.qualify(:categories).ilike("%#{query}%"))
      end

      def validate
        super
        validates_presence [:name, :slug]
        validates_format %r{^[a-z0-9][a-z0-9-]*[a-z0-9]$}, [:slug]
        validates_unique [:slug]
      end
    end
  end
end
