module Facts
  module Models
    class Fact < Sequel::Model
      many_to_one :category
      plugin :timestamps
      plugin :validation_helpers
      set_allowed_columns :category, :category_id, :content

      def validate
        super
        validates_presence [:category_id, :content]
      end
    end
  end
end
