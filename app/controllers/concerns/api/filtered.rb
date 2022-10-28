module Api::Filtered
  extend ActiveSupport::Concern

  def filtered_collection(collection, bool = true)
    collection.ransack(query_string_filters).result(distinct: bool)
  end

  private

  def query_string_filters
    return {} if params[:q].blank?

    params[:q]&.to_unsafe_h || {}
  end
end
