module PowerApi
  class BaseController < ApplicationController
    include Api::Error
    include Api::Deprecated
    include Api::Versioned

    self.responder = ApiResponder

    respond_to :json
  end
end
