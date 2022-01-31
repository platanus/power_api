class Api::Internal::BlogsController < Api::Internal::BaseController
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
    blog.update!(blog_params)
    respond_with blog
  end

  def destroy
    respond_with blog.destroy!
  end

  private

  def blog
    @blog ||= Blog.find_by!(id: params[:id])
  end

  def blog_params
    params.require(:blog).permit(
      :title,
      :body,
      :portfolio_id
    )
  end
end
