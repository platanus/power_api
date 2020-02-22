shared_examples 'ActiveRecord resource' do
  describe "#upcase" do
    def perform
      resource.upcase
    end

    it { expect(perform).to eq("BLOG") }
  end

  describe "#upcase_plural" do
    def perform
      resource.upcase_plural
    end

    it { expect(perform).to eq("BLOGS") }
  end

  describe "#camel" do
    def perform
      resource.camel
    end

    it { expect(perform).to eq("Blog") }
  end

  describe "#plural" do
    def perform
      resource.plural
    end

    it { expect(perform).to eq("blogs") }
  end

  describe "#snake_case" do
    def perform
      resource.snake_case
    end

    it { expect(perform).to eq("blog") }
  end

  describe "#titleized" do
    def perform
      resource.titleized
    end

    it { expect(perform).to eq("Blog") }
  end

  describe "#plural_titleized" do
    def perform
      resource.plural_titleized
    end

    it { expect(perform).to eq("Blogs") }
  end

  describe "#resource_name=" do
    context "with invalid resource name" do
      let(:resource_name) { "ticket" }

      it { expect { generators_helper }.to raise_error(/Invalid resource name/) }
    end

    context "with missing resource name" do
      let(:resource_name) { "" }

      it { expect { generators_helper }.to raise_error(/Invalid resource name/) }
    end

    context "when resource is not an active record model" do
      let(:resource_name) { "power_api" }

      it { expect { generators_helper }.to raise_error("resource is not an active record model") }
    end
  end

  describe "#class_definition_line" do
    def perform
      resource.class_definition_line
    end

    it { expect(perform).to eq("class Blog < ApplicationRecord\n") }
  end

  describe "#path" do
    def perform
      resource.path
    end

    it { expect(perform).to eq("app/models/blog.rb") }
  end
end
