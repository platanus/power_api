require 'spec_helper'

describe 'Api::Error', type: :controller do
  before do
    routes.draw { get :action, to: "anonymous#action" }

    get :action
  end

  def response_body
    JSON.parse(response.body).deep_symbolize_keys
  end

  context "with Exception error" do
    let(:expected_response) do
      {
        detail: ":-(",
        message: "server_error",
        type: "RuntimeError"
      }
    end

    controller do
      include ::Api::Error

      def action
        raise ':-('
      end
    end

    it { expect(response_body).to eq(expected_response) }
    it { expect(response.status).to eq(500) }
  end

  context "with ActiveRecord::RecordNotFound error" do
    let(:expected_response) do
      {
        detail: ":-(",
        message: "record_not_found"
      }
    end

    controller do
      include ::Api::Error

      def action
        raise ActiveRecord::RecordNotFound.new(":-(")
      end
    end

    it { expect(response_body).to eq(expected_response) }
    it { expect(response.status).to eq(404) }
  end

  context "with ActiveModel::ForbiddenAttributesError error" do
    let(:expected_response) do
      {
        detail: ":-(",
        message: "protected_attributes"
      }
    end

    controller do
      include ::Api::Error

      def action
        raise ActiveModel::ForbiddenAttributesError.new(":-(")
      end
    end

    it { expect(response_body).to eq(expected_response) }
    it { expect(response.status).to eq(400) }
  end

  context "with ActiveRecord::RecordInvalid error" do
    let(:expected_response) do
      {
        message: "invalid_attributes",
        errors: {
          body: ["can't be blank"],
          title: ["can't be blank"]
        }
      }
    end

    controller do
      include ::Api::Error

      def action
        raise Blog.create!
      end
    end

    it { expect(response_body).to eq(expected_response) }
    it { expect(response.status).to eq(400) }
  end
end
