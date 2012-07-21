module Facts
  module Api
    module FactHelpers
      @@serializer = Serializers::FactSerializer.new(:v0)

      def serialize(obj)
        @@serializer.serialize(obj)
      end
    end
  end
end
