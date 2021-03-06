module PowerApi::GeneratorHelper::SimpleTokenAuthHelper
  extend ActiveSupport::Concern

  class SimpleTokenAuthResource
    include PowerApi::GeneratorHelper::ActiveRecordResource
    include PowerApi::GeneratorHelper::ResourceHelper

    def initialize(resource)
      self.resource_name = resource
    end

    def authenticated_resource_migration
      "migration add_authentication_token_to_#{plural} \
authentication_token:string{30}:uniq"
    end
  end

  included do
    attr_reader :authenticated_resources, :authenticated_resource
    attr_accessor :owned_by_authenticated_resource
  end

  def authenticated_resources=(values)
    @authenticated_resources = values.map { |value| SimpleTokenAuthResource.new(value) }
  end

  def authenticated_resource=(value)
    return if value.blank?

    @authenticated_resource = SimpleTokenAuthResource.new(value)
  end

  def authenticated_resource?
    !!authenticated_resource
  end

  def owned_by_authenticated_resource?
    owned_by_authenticated_resource && authenticated_resource? && !parent_resource?
  end

  def current_authenticated_resource
    "current_#{authenticated_resource.snake_case}"
  end

  def simple_token_auth_method
    <<-METHOD
  acts_as_token_authenticatable

    METHOD
  end

  def simple_token_auth_initializer_path
    "config/initializers/simple_token_authentication.rb"
  end

  def simple_token_auth_initializer_tpl
    <<~INITIALIZER
      SimpleTokenAuthentication.configure do |config|
        # Configure the session persistence policy after a successful sign in,
        # in other words, if the authentication token acts as a signin token.
        # If true, user is stored in the session and the authentication token and
        # email may be provided only once.
        # If false, users must provide their authentication token and email at every request.
        # config.sign_in_token = false

        # Configure the name of the HTTP headers watched for authentication.
        #
        # Default header names for a given token authenticatable entity follow the pattern:
        #   { entity: { authentication_token: 'X-Entity-Token', email: 'X-Entity-Email'} }
        #
        # When several token authenticatable models are defined, custom header names
        # can be specified for none, any, or all of them.
        #
        # Note: when using the identifiers options, this option behaviour is modified.
        # Please see the example below.
        #
        # Examples
        #
        #   Given User and SuperAdmin are token authenticatable,
        #   When the following configuration is used:
        #     `config.header_names = { super_admin: { authentication_token: 'X-Admin-Auth-Token' } }`
        #   Then the token authentification handler for User watches the following headers:
        #     `X-User-Token, X-User-Email`
        #   And the token authentification handler for SuperAdmin watches the following headers:
        #     `X-Admin-Auth-Token, X-SuperAdmin-Email`
        #
        #   When the identifiers option is set:
        #     `config.identifiers = { super_admin: :phone_number }`
        #   Then both the header names identifier key and default value are modified accordingly:
        #     `config.header_names = { super_admin: { phone_number: 'X-SuperAdmin-PhoneNumber' } }`
        #
        # config.header_names = { user: { authentication_token: 'X-User-Token', email: 'X-User-Email' } }

        # Configure the name of the attribute used to identify the user for authentication.
        # That attribute must exist in your model.
        #
        # The default identifiers follow the pattern:
        # { entity: 'email' }
        #
        # Note: the identifer must match your Devise configuration,
        # see https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#tell-devise-to-use-username-in-the-authentication_keys
        #
        # Note: setting this option does modify the header_names behaviour,
        # see the header_names section above.
        #
        # Example:
        #
        #   `config.identifiers = { super_admin: 'phone_number', user: 'uuid' }`
        #
        # config.identifiers = { user: 'email' }

        # Configure the Devise trackable strategy integration.
        #
        # If true, tracking is disabled for token authentication: signing in through
        # token authentication won't modify the Devise trackable statistics.
        #
        # If false, given Devise trackable is configured for the relevant model,
        # then signing in through token authentication will be tracked as any other sign in.
        #
        # config.skip_devise_trackable = true
      end
    INITIALIZER
  end
end
