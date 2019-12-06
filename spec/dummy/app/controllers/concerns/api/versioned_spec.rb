require 'spec_helper'

describe 'Api::Versioned', type: :controller do
  let(:available_versions) { 1 }
  let(:headers) do
    {}
  end

  before do
    allow(ENV).to receive(:fetch).with(
      "AVAILABLE_API_VERSIONS", 1
    ).and_return(available_versions)

    routes.draw { get :action, to: "anonymous#action" }
    request.headers.merge!(headers) unless headers.blank?
    get :action
  end

  controller do
    include ::Api::Versioned
    include ::Api::Error

    def action
      head :ok
    end
  end

  context "with default version" do
    it { expect(response.status).to eq(200) }
    it { expect(response.headers["Content-Type"]).to eq("text/html; version=1") }

    context "with invalid version header" do
      let(:headers) do
        {
          "Accept" => "version=2"
        }
      end

      it { expect(response.status).to eq(400) }
    end
  end

  context "with multiple versions" do
    let(:available_versions) { 2 }
    let(:headers) do
      {
        "Accept" => "version=2"
      }
    end

    it { expect(response.status).to eq(200) }
    it { expect(response.headers["Content-Type"]).to eq("text/html; version=2") }

    context "with invalid version header" do
      let(:headers) do
        {
          "Accept" => "version=3"
        }
      end

      it { expect(response.status).to eq(400) }
    end
  end
end
