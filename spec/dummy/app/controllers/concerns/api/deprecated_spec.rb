require 'spec_helper'

describe 'Api::Deprecated', type: :controller do
  before do
    routes.draw { get :action1, to: "anonymous#action" }

    get :action
  end

  context "with deprecated action" do
    controller do
      include ::Api::Deprecated

      deprecate :action

      def action
        head :ok
      end
    end

    it { expect(response.status).to eq(200) }
    it { expect(response.headers["Deprecated"]).to eq(true) }
  end

  context "with deprecated action" do
    controller do
      include ::Api::Deprecated

      def action
        head :ok
      end
    end

    it { expect(response.status).to eq(200) }
    it { expect(response.headers["Deprecated"]).to be_nil }
  end
end
