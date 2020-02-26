RSpec.describe PowerApi::GeneratorHelper::SimpleTokenAuthHelper, type: :generator do
  describe "#authenticated_resource" do
    let(:authenticated_resource) { "blog" }
    let(:resource) { generators_helper.authenticated_resource }

    it_behaves_like('ActiveRecord resource') do
      describe "#authenticated_resources_migrations" do
        let(:expected) do
          "migration add_authentication_token_to_blogs authentication_token:string{30}:uniq"
        end

        it { expect(resource.authenticated_resource_migration).to eq(expected) }
      end

      describe "current_authenticated_resource" do
        it { expect(generators_helper.current_authenticated_resource).to eq("current_blog") }
      end
    end
  end

  describe "#authenticated_resources=" do
    let(:resources_names) { ["blog"] }
    let(:resource) { resources.first }

    def resources
      generators_helper.authenticated_resources = resources_names
      generators_helper.authenticated_resources
    end

    it { expect(resources.count).to eq(1) }
    it { expect(resources.first).to be_a(described_class::SimpleTokenAuthResource) }

    it_behaves_like('ActiveRecord resource') do
      describe "#authenticated_resources_migrations" do
        let(:expected) do
          "migration add_authentication_token_to_blogs authentication_token:string{30}:uniq"
        end

        it { expect(resource.authenticated_resource_migration).to eq(expected) }
      end
    end
  end

  describe "#owned_by_authenticated_resource?" do
    let(:authenticated_resource) { "user" }
    let(:owned_by_authenticated_resource) { true }
    let(:parent_resource_name) { nil }

    def perform
      generators_helper.owned_by_authenticated_resource?
    end

    it { expect(perform).to eq(true) }

    context "with no authenticated_resource" do
      let(:authenticated_resource) { nil }

      it { expect(perform).to eq(false) }
    end

    context "with no owned_by_authenticated_resource" do
      let(:owned_by_authenticated_resource) { false }

      it { expect(perform).to eq(false) }
    end

    context "with parent_resource" do
      let(:parent_resource_name) { "user" }

      it { expect(perform).to eq(false) }
    end
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
