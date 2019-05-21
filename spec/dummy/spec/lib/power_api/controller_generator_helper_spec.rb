require "rails_helper"

describe PowerApi::ControllerGeneratorHelper do
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

  describe "generate_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::V1::BlogController < Api::V1::BaseController
          def index
            respond_with Blog.all
          end

          def show
            respond_with blog
          end

          def create
            respond_with Blog.create!(blog_params)
          end

          def update
            respond_with blog.update!(blog_params)
          end

          def destroy
            blog.destroy!
          end

          private

          def blog
            @blog ||= Blog.find_by!(id: params[:id])
          end

          def blog_params
            params.require(:blog).permit(:name)
          end
        end
      CONTROLLER
    end

    def perform
      subject.generate_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end
end
