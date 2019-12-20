require "active_model_serializers"
require "api-pagination"
require "kaminari"
require "ransack"
require "responders"
require "rswag/api"
require "rswag/ui"
require "rswag/specs"
require "simple_token_authentication"
require "versionist"

require "power_api/engine"

module PowerApi
  extend self

  # You can add, in this module, your own configuration options as in the example below...
  #
  # attr_writer :my_option
  #
  # def my_option
  #   return "Default Value" unless @my_option
  #   @my_option
  # end
  #
  # Then, you can customize the default behaviour (typically in a Rails initializer) like this:
  #
  # PowerApi.setup do |config|
  #   config.root_url = "Another value"
  # end

  def setup
    yield self
    require "power_api"
  end
end
