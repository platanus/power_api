RSpec.describe PowerApi::GeneratorHelper::SimpleTokenAuthHelper, type: :generator do
  let(:resource_name) { "blog" }

  def auth_resource
    generators_helper.authenticated_resource = resource_name
    generators_helper.authenticated_resource
  end

  describe "#authenticated_resources=" do
    let(:resources_names) { [resource_name] }

    def resources
      generators_helper.authenticated_resources = resources_names
      generators_helper.authenticated_resources
    end

    it { expect(resources.count).to eq(1) }
    it { expect(resources.first.upcase_resource).to eq("BLOG") }

    context "with invalid resource name" do
      let(:resources_names) { ["ticket"] }

      it { expect { resources }.to raise_error(/Invalid resource name/) }
    end

    context "with missing resource name" do
      let(:resources_names) { [""] }

      it { expect { resources }.to raise_error(/Invalid resource name/) }
    end

    context "when resource is not an active record model" do
      let(:resources_names) { ["power_api"] }

      it { expect { resources }.to raise_error("resource is not an active record model") }
    end
  end

  describe "#authenticated_resources_migrations" do
    let(:expected) do
      "migration add_authentication_token_to_blogs authentication_token:string{30}:uniq"
    end

    it { expect(auth_resource.authenticated_resource_migration).to eq(expected) }
  end

  describe "current_resource" do
    before { auth_resource }

    it { expect(generators_helper.current_resource).to eq("current_blog") }
  end

  describe "#simple_token_auth_method" do
    let(:expected) do
      "  acts_as_token_authenticatable\n\n"
    end

    it { expect(generators_helper.simple_token_auth_method).to eq(expected) }
  end

  describe "#simple_token_auth_initializer_path" do
    let(:expected_path) { "spec/swagger/.gitkeep" }

    def perform
      generators_helper.simple_token_auth_initializer_path
    end

    it { expect(perform).to eq("config/initializers/simple_token_authentication.rb") }
  end

  describe "#simple_token_auth_initializer_tpl" do
    let(:expected) do
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

    it { expect(generators_helper.simple_token_auth_initializer_tpl).to eq(expected) }
  end
end
