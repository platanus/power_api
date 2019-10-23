module PowerApi
  class BaseController < ApplicationController
    include Api::Error

    self.responder = ApiResponder

    respond_to :json
  end
end
