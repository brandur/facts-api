require "active_record"
require "grape"

require "facts/monkey_patch"

require "facts/api/v0"
require "facts/api_aggregate"

require "facts/models/category"
require "facts/models/fact"

require "facts/serializers/base"
require "facts/serializers/category_serializer"
require "facts/serializers/fact_serializer"
