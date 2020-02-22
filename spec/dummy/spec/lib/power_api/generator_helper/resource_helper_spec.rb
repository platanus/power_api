RSpec.describe PowerApi::GeneratorHelper::ResourceHelper, type: :generator do
  describe "#resource" do
    let(:resource) { generators_helper.resource }

    it_behaves_like('ActiveRecord resource')
    it_behaves_like('ActiveRecord resource attributes', :resource_attributes)
  end

  describe "#parent_resource" do
    let(:parent_resource_name) { "blog" }
    let(:resource) { generators_helper.parent_resource }

    it_behaves_like('ActiveRecord resource')
  end

  describe "#parent_resource?" do
    let(:parent_resource_name) { "blog" }

    def perform
      generators_helper.parent_resource?
    end

    it { expect(perform).to eq(true) }

    context "with no parent resource name" do
      let(:parent_resource_name) { nil }

      it { expect(perform).to eq(false) }
    end
  end
end
