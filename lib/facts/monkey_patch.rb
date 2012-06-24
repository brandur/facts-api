module Rack
  class Request
    def id
      env["REQUEST_ID"]
    end
  end
end

class String
  def blank?
    puts "called blank"
    respond_to?(:empty?) ? empty? : !self
  end

  def parse_json
    JSON.parse(self)
  end
end
