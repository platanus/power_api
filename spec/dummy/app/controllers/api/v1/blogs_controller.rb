class Api::V1::BlogsController < Api::V1::BaseController
  def index
    respond_with paginate(filtered_collection(Blog.all))
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
    params.require(:blog).permit(
      :title, :body, :created_at, :updated_at
    )
  end
end
