require "rails_helper"

describe PowerApi::TemplateGenerator do
  let(:version_number) { "1" }
  let(:resource_name) { "blog" }
  let(:init_params) do
    {
      version_number: version_number,
      resource_name: resource_name
    }
  end

  subject { described_class.new(init_params) }

  context "with valid init params" do
    it { expect(subject.version_number).to eq(1) }
    it { expect(subject.resource_name).to eq("blog") }
  end

  context "with invalid version number" do
    let(:version_number) { "A" }

    it { expect { subject }.to raise_error("invalid version number") }
  end

  context "with zero version number" do
    let(:version_number) { 0 }

    it { expect { subject }.to raise_error("invalid version number") }
  end

  context "with nil version number" do
    let(:version_number) { nil }

    it { expect { subject }.to raise_error("invalid version number") }
  end

  context "with nil blank number" do
    let(:version_number) { "" }

    it { expect { subject }.to raise_error("invalid version number") }
  end

  context "with negative version number" do
    let(:version_number) { -1 }

    it { expect { subject }.to raise_error("invalid version number") }
  end

  context "with invalid resource name" do
    let(:resource_name) { "ticket" }

    it { expect { subject }.to raise_error("resource is not an active record model") }
  end

  context "with missing resource name" do
    let(:resource_name) { "" }

    it { expect { subject }.to raise_error("missing resource name") }
  end
end
