require 'spec_helper'

describe 'Api::Filtered', type: :controller do
  let(:filters) do
    nil
  end

  controller do
    include ::Api::Filtered

    def action
      render json: filtered_collection(Blog.all)
    end
  end

  before do
    routes.draw { get :action, to: "anonymous#action" }

    create(:blog, title: "Lean's blog")
    create(:blog, title: "Santiago's blog")

    get :action, params: { q: filters }
  end

  def resources_count
    JSON.parse(response.body).count
  end

  it { expect(resources_count).to eq(2) }
  it { expect(response.status).to eq(200) }

  context "with filters" do
    let(:filters) do
      {
        title_cont: "Lean"
      }
    end

    it { expect(resources_count).to eq(1) }
    it { expect(response.status).to eq(200) }
  end
end
