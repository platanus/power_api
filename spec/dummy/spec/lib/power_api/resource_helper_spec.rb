describe PowerApi::ResourceHelper do
  let(:resource_name) { "blog" }
  let(:class_definition) do
    Proc.new do
      include PowerApi::ResourceHelper

      attr_reader :resource_name

      def initialize(resource_name)
        @resource_name = resource_name
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

    context "with undefined resource_name reader" do
      let(:class_definition) do
        Proc.new do
          include PowerApi::ResourceHelper

          def initialize(resource_name)
            @resource_name = resource_name
          end
        end
      end

      it { expect { perform }.to raise_error("resource_name not implemented") }
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

  describe "#snake_case_resource" do
    let(:resource_name) { "AdminUser" }

    def perform
      subject.snake_case_resource
    end

    it { expect(perform).to eq("admin_user") }
  end

  describe "#validate_resource_name!" do
    def perform
      subject.validate_resource_name!(resource_name)
    end

    context "with valid resource_name" do
      let(:resource_name) { "blog" }

      it { expect(perform).to eq(true) }
    end

    context "with invalid resource name" do
      let(:resource_name) { "ticket" }

      it { expect { perform }.to raise_error("resource is not an active record model") }
    end

    context "with missing resource name" do
      let(:resource_name) { "" }

      it { expect { perform }.to raise_error("missing resource name") }
    end
  end
end
