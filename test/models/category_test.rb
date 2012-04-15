require "test_helper"

module Facts
  module Models
    describe Fact do
      let(:fact) do
        Models::Fact.new(content: "The world is **big**.").tap do |f|
          f.category = Models::Category.new(name: 'World', slug: 'world')
        end
      end

      it "is valid" do
        fact.valid?.must_equal true
      end

      it "renders content as markdown" do
        fact.content_html.must_match %r{The world is <strong>big</strong>.}
      end

      describe "scopes" do
        before do
          fact.save if fact.new_record?
        end

        it "has random scope" do
          Fact.random.first.content.must_equal fact.content
        end

        it "has searches" do
          Fact.search("big").first.content.must_equal fact.content
          Fact.search("sri lanka").first.must_be_nil
        end
      end
    end
  end
end
