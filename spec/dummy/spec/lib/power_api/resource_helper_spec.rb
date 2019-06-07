describe PowerApi::ResourceHelper do
  let(:resource_name) { "blog" }
  let(:class_definition) do
    Proc.new do
      include PowerApi::ResourceHelper

      def initialize(resource_name)
        self.resource_name = resource_name
      end
    end
  end

  before { create_test_class(&class_definition) }

  subject { TestClass.new(resource_name) }

  describe "#resource_name" do
    def perform
      subject.resource_name
    end

    it { expect(perform).to eq("blog") }
  end

  describe "#resource_name=" do
    context "with invalid resource name" do
      let(:resource_name) { "ticket" }

      it { expect { subject }.to raise_error("resource is not an active record model") }
    end

    context "with missing resource name" do
      let(:resource_name) { "" }

      it { expect { subject }.to raise_error("missing resource name") }
    end
  end

  describe "#camel_resource" do
    def perform
      subject.camel_resource
    end

    it { expect(perform).to eq("Blog") }
  end

  describe "#plural_resource" do
    def perform
      subject.plural_resource
    end

    it { expect(perform).to eq("blogs") }
  end

  describe "#resource_class" do
    def perform
      subject.resource_class
    end

    it { expect(perform).to eq(Blog) }
  end

  describe "#snake_case_resource" do
    def perform
      subject.snake_case_resource
    end

    it { expect(perform).to eq("blog") }
  end
end
