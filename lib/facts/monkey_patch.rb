class String
  def blank?
    puts "called blank"
    respond_to?(:empty?) ? empty? : !self
  end

  def parse_json
    JSON.parse(self)
  end
end
