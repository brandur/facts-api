module Facts
  class ApiError < StandardError
    attr_accessor :status
    def initialize(message, status=500)
      self.status = status
      super(message)
    end
  end

  class BadRequest < ApiError
    def initialize(message = nil)
      super(message || "Bad request", 400)
    end
  end

  class Unauthorized < ApiError
    def initialize(message = nil)
      super(message || "Unauthorized", 401)
    end
  end

  API_ERRORS = [
    BadRequest,
    Unauthorized,
  ]
end
