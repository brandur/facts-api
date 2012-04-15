module Facts
  module Serializers
    class Base
      def initialize(form)
        @form = form
      end

      def serialize(obj)
        if obj.respond_to?(:map)
          obj.map{ |o| serialize(o) }
        else
          send(@form, obj)
        end
      end
    end
  end
end
