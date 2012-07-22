require "test_helper"

module Facts
  module Models
    describe Fact do
      let(:fact) { Fact.new(category_id: 1, content: "The world is **big**.") }

      it "is valid" do
        fact.valid?.must_equal true
      end
    end
  end
end
