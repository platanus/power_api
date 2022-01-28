class Api::Internal::BaseController < Api::BaseController
  before_action do
    self.namespace_for_serializer = ::Api::Internal
  end
end
