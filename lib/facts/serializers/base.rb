module Facts
  module Serializers
    class Base
      def initialize(form)
        @form = form
      end

      def serialize(obj)
        if obj.nil?
          nil
        elsif obj.respond_to?(:map)
          obj.map{ |o| serialize(o) }
        else
          prepare(send(@form, obj))
        end
      end

      private

      def prepare(hash)
        hash.each do |k, v|
          hash[k] = v.iso8601 if v.respond_to?(:iso8601)
        end
        hash
      end
    end
  end
end
