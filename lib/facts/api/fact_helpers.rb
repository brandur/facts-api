module Facts
  module Api
    module FactHelpers
      @@serializer = Serializers::FactSerializer.new(:api)

      def serialize(obj)
        @@serializer.serialize(obj)
      end
    end
  end
end
