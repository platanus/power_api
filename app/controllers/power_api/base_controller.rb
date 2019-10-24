module PowerApi
  class BaseController < ApplicationController
    include Api::Error
    include Api::Deprecated

    self.responder = ApiResponder

    respond_to :json
  end
end
