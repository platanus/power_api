# Power API

[![Gem Version](https://badge.fury.io/rb/power_api.svg)](https://badge.fury.io/rb/power_api)
[![CircleCI](https://circleci.com/gh/platanus/power_api.svg?style=shield)](https://app.circleci.com/pipelines/github/platanus/power_api)
[![Coverage Status](https://coveralls.io/repos/github/platanus/power_api/badge.svg?branch=master)](https://coveralls.io/github/platanus/power_api?branch=master)

It's a Rails engine that gathers a set of gems and configurations designed to build incredible REST APIs.

These gems are:

- [API Pagination](https://github.com/davidcelis/api-pagination): to handle issues related to pagination.
- [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers): to handle API response format.
- [Ransack](https://github.com/activerecord-hackery/ransack): to handle filters.
- [Responders](https://github.com/heartcombo/responders): to dry up your API.
- [Rswag](https://github.com/rswag/rswag): to test and document the API.
- [Simple Token Authentication](https://github.com/gonzalo-bulnes/simple_token_authentication): to authenticate your resources.
- [Versionist](https://github.com/bploetz/versionist): to handle the API versioning.

> To understand what this gem does, it is recommended to read first about those mentioned above.


## Content

- [Power API](#power-api)
  - [Content](#content)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Initial Setup](#initial-setup)
    - [Exposed API mode](#exposed-api-mode)
      - [Command options:](#command-options)
        - [`--authenticated-resources`](#--authenticated-resources)
    - [Internal API mode](#internal-api-mode)
    - [Version Creation (exposed mode only)](#version-creation-exposed-mode-only)
    - [Controller Generation (exposed and internal modes)](#controller-generation-exposed-and-internal-modes)
      - [Command options (valid for internal and exposed modes):](#command-options-valid-for-internal-and-exposed-modes)
        - [`--attributes`](#--attributes)
        - [`--controller-actions`](#--controller-actions)
        - [`--version-number`](#--version-number)
        - [`--use-paginator`](#--use-paginator)
        - [`--allow-filters`](#--allow-filters)
        - [`--authenticate-with`](#--authenticate-with)
        - [`--owned-by-authenticated-resource`](#--owned-by-authenticated-resource)
        - [`--parent-resource`](#--parent-resource)
  - [Inside the gem](#inside-the-gem)
    - [The `Api::Error` concern](#the-apierror-concern)
    - [The `Api::Deprecated` concern](#the-apideprecated-concern)
    - [The `ApiResponder`](#the-apiresponder)
    - [The `PowerApi::ApplicationHelper#serialize_resource` helper method](#the-powerapiapplicationhelperserialize_resource-helper-method)
  - [Testing](#testing)
  - [Publishing](#publishing)
  - [Contributing](#contributing)
  - [Credits](#credits)
  - [License](#license)

## Installation

Add to your Gemfile:

```ruby
gem 'power_api'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'rubocop'
  gem 'rubocop-rspec'
end
```

Then,

```bash
bundle install
```

## Usage

### Initial Setup

You must run the following command to have the initial configuration:

```bash
rails generate power_api:install
```

After doing this you will get:

- A base controller for your API under `/your_app/app/controllers/api/base_controller.rb`
  ```ruby
  class Api::BaseController < PowerApi::BaseController
  end
  ```
  Here you should include everything common to all your APIs. It is usually empty because most of the configuration comes in the `PowerApi::BaseController` that is inside the gem.

- Some initializers:
  - `/your_api/config/initializers/active_model_serializers.rb`:
    ```ruby
    ActiveModelSerializers.config.adapter = :json
    ```

  - `/your_api/config/initializers/api_pagination.rb`:
    ```ruby
    ApiPagination.configure do |config|
      config.paginator = :kaminari

      # more options...
    end
    ```
    We use what comes by default and kaminari as pager.

After running the installer you must choose an API mode.
### Exposed API mode

Use this mode if your API will be accessed by multiple clients or if your API is served somewhere other than your client application.

You must run the following command to have the exposed API mode configuration:

```bash
rails generate power_api:exposed_api_config
```

After doing this you will get:

- A base controller for the first version of your API under `/your_api/app/controllers/api/exposed/v1/base_controller.rb`
  ```ruby
  class Api::Exposed::V1::BaseController < Api::BaseController
    before_action do
      self.namespace_for_serializer = ::Api::V1
    end
  end
  ```
  Everything related to version 1 of your API must be included here.

- Some initializers:
  - `/your_api/config/initializers/rswag-api.rb`:
    ```ruby
    Rswag::Api.configure do |c|
      c.swagger_root = Rails.root.to_s + '/swagger'
    end
    ```
    We use the default options but setting the `your_api/swagger` directory as container for the generated Swagger JSON files.

  - `/your_api/config/initializers/rswag-ui.rb`:
    ```ruby
    Rswag::Ui.configure do |c|
      c.swagger_endpoint '/api-docs/v1/swagger.json', 'API V1 Docs'
    end
    ```
    We configure the first version to be seen in the documentation view.

  - `/your_api/config/initializers/simple_token_authentication.rb`:
    ```ruby
    SimpleTokenAuthentication.configure do |config|
      # options...
    end
    ```
    We use the default options.
- A modified `/your_api/config/routes.rb` file:
  ```ruby
  Rails.application.routes.draw do
    scope path: '/api' do
      api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
      end
    end
    mount Rswag::Api::Engine => '/api-docs'
    mount Rswag::Ui::Engine => '/api-docs'
    # ...
  end
  ```
  Here we create the first version with [Versionist](https://github.com/bploetz/versionist) and mount Rswag.
- A file with the swagger definition for the first version under `/your_api/spec/swagger/v1/definition.rb`
  ```ruby
  API_V1 = {
    swagger: '2.0',
    info: {
      title: 'API V1',
      version: 'v1'
    },
    basePath: '/api/v1',
    definitions: {
    }
  }
  ```
- The `/your_api/spec/swagger_helper.rb` (similar to rails_helper.rb file):
  ```ruby
  require 'rails_helper'

  Dir[::Rails.root.join("spec/swagger/**/schemas/*.rb")].each { |f| require f }
  Dir[::Rails.root.join("spec/swagger/**/definition.rb")].each { |f| require f }

  RSpec.configure do |config|
    # Specify a root folder where Swagger JSON files are generated
    # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
    # to ensure that it's confiugred to serve Swagger from the same folder
    config.swagger_root = Rails.root.to_s + '/swagger'

    # Define one or more Swagger documents and provide global metadata for each one
    # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
    # be generated at the provided relative path under swagger_root
    # By default, the operations defined in spec files are added to the first
    # document below. You can override this behavior by adding a swagger_doc tag to the
    # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
    config.swagger_docs = {
      'v1/swagger.json' => API_V1
    }
  end
  ```
- An empty directory indicating where you should put your serializers for the first version: `/your_api/app/serializers/api/exposed/v1/.gitkeep`
- An empty directory indicating where you should put your API tests: `/your_api/spec/integration/.gitkeep`
- An empty directory indicating where you should put your swagger schemas `/your_api/spec/swagger/v1/schemas/.gitkeep`

#### Command options:

##### `--authenticated-resources`

Use this option if you want to configure [Simple Token Authentication](https://github.com/gonzalo-bulnes/simple_token_authentication) for one or more models.

```bash
rails g power_api:install --authenticated-resources=user
```

Running the above code will generate, in addition to everything described in the initial setup, the following:

- The [Simple Token Authentication](https://github.com/gonzalo-bulnes/simple_token_authentication) initializer `/your_api/config/initializers/simple_token_authentication.rb`

- An edited version of the User model with the configuration needed for Simple Token Authentication.

  ```ruby
  class User < ApplicationRecord
    acts_as_token_authenticatable

    # more code...
  end
  ```
- The migration `/your_api/db/migrate/20200228173608_add_authentication_token_to_users.rb` to add the `authentication_token` to your users table.

### Internal API mode

Use this mode if your API and your client app will be served on the same place.

You must run the following command to have the internal API mode configuration:

```bash
rails generate power_api:internal_api_config
```

After doing this you will get:

- A base controller for your internal API under `/your_api/app/controllers/api/internal/base_controller.rb`
  ```ruby
  class Api::Internal::BaseController < Api::BaseController
    before_action do
      self.namespace_for_serializer = ::Api::Internal
    end
  end
  ```
  Anything shared by the internal API controllers should go here.

- A modified `/your_api/config/routes.rb` file:
  ```ruby
  namespace :api, defaults: { format: :json } do
    namespace :internal do
    end
  end
  ```

- An empty directory indicating where you should put your serializers: `/your_api/app/serializers/api/internal/.gitkeep`

### Version Creation (exposed mode only)

To add a new version you must run the following command:
```bash
rails g power_api:version VERSION_NUMBER
```
Example:
```bash
rails g power_api:version 2
```

Doing this will add the same thing that was added for version one in the initial setup but this time for the number version provided as parameter.

### Controller Generation (exposed and internal modes)

To add a controller you must run the following command:
```bash
rails g power_api:controller MODEL_NAME [options]
```
Example:
```bash
rails g power_api:controller blog
```
Assuming we have the following model,

```ruby
class Blog < ApplicationRecord
# == Schema Information
#
# Table name: blogs
#
#  id         :bigint(8)        not null, primary key
#  title      :string(255)
#  body       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
end
```

after doing this you will get:

- A modified `/your_api/config/routes.rb` file with the new resource:
  - Exposed mode:
    ```ruby
    Rails.application.routes.draw do
      scope path: '/api' do
        api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
          resources :blogs
        end
      end
    end
    ```
  - Internal mode:
    ```ruby
    Rails.application.routes.draw do
      namespace :api, defaults: { format: :json } do
        namespace :internal do
          resources :blogs
        end
      end
    end
    ```
- A controller under `/your_api/app/controllers/api/exposed/v1/blogs_controller.rb`
  ```ruby
  class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
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
      respond_with blog.update!(blog_params)
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
        :id,
        :title,
        :body,
      )
    end
  end
  ```
  > With internal mode the file path will be: `/your_api/app/controllers/api/internal/blogs_controller.rb` and the class name: `Api::Internal::BlogsController`

- A serializer under `/your_api/app/serializers/api/exposed/v1/blog_serializer.rb`
  ```ruby
  class Api::Exposed::V1::BlogSerializer < ActiveModel::Serializer
    type :blog

    attributes(
      :id,
      :title,
      :body,
      :created_at,
      :updated_at
    )
  end
  ```
  > With internal mode the file path will be: `/your_api/app/serializers/api/internal/blog_serializer.rb` and the class name: `Api::Internal::BlogSerializer`

- A spec file under `/your_api/spec/integration/api/exposed/v1/blogs_spec.rb`
  - Exposed mode:
  ```ruby
  require 'swagger_helper'

  describe 'API V1 Blogs', swagger_doc: 'v1/swagger.json' do
    path '/blogs' do
      get 'Retrieves Blogs' do
        description 'Retrieves all the blogs'
        produces 'application/json'

        let(:collection_count) { 5 }
        let(:expected_collection_count) { collection_count }

        before { create_list(:blog, collection_count) }

        response '200', 'Blogs retrieved' do
          schema('$ref' => '#/definitions/blogs_collection')

          run_test! do |response|
            expect(JSON.parse(response.body)['blogs'].count).to eq(expected_collection_count)
          end
        end
      end

      post 'Creates Blog' do
        description 'Creates Blog'
        consumes 'application/json'
        produces 'application/json'
        parameter(name: :blog, in: :body)

        response '201', 'blog created' do
          let(:blog) do
            {
              title: 'Some title',
              body: 'Some body'
            }
          end

          run_test!
        end

        response '400', 'invalid attributes' do
          let(:blog) do
            {
              title: nil
            }
          end

          run_test!
        end
      end
    end

    path '/blogs/{id}' do
      parameter name: :id, in: :path, type: :integer

      let(:existent_blog) { create(:blog) }
      let(:id) { existent_blog.id }

      get 'Retrieves Blog' do
        produces 'application/json'

        response '200', 'blog retrieved' do
          schema('$ref' => '#/definitions/blog_resource')

          run_test!
        end

        response '404', 'invalid blog id' do
          let(:id) { 'invalid' }
          run_test!
        end
      end

      put 'Updates Blog' do
        description 'Updates Blog'
        consumes 'application/json'
        produces 'application/json'
        parameter(name: :blog, in: :body)

        response '200', 'blog updated' do
          let(:blog) do
            {
              title: 'Some title',
              body: 'Some body'
            }
          end

          run_test!
        end

        response '400', 'invalid attributes' do
          let(:blog) do
            {
              title: nil
            }
          end

          run_test!
        end
      end

      delete 'Deletes Blog' do
        produces 'application/json'
        description 'Deletes specific blog'

        response '204', 'blog deleted' do
          run_test!
        end

        response '404', 'blog not found' do
          let(:id) { 'invalid' }

          run_test!
        end
      end
    end
  end

  ```
  - Internal mode:
  ```ruby
  require 'rails_helper'

  describe 'Api::Internal::BlogsControllers', type: :request do
    describe 'GET /index' do
      let!(:blogs) { create_list(:blog, 5) }
      let(:collection) { JSON.parse(response.body)['blogs'] }
      let(:params) { {} }

      def perform
        get '/api/internal/blogs', params: params
      end

      before do
        perform
      end

      it { expect(collection.count).to eq(5) }
      it { expect(response.status).to eq(200) }
    end

    describe 'POST /create' do
      let(:params) do
        {
          blog: {
            title: 'Some title'
          }
        }
      end

      let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
      end

      def perform
        post '/api/internal/blogs', params: params
      end

      before do
        perform
      end

      it { expect(attributes).to include(params[:blog]) }
      it { expect(response.status).to eq(201) }

      context 'with invalid attributes' do
        let(:params) do
          {
            blog: {
              title: nil
            }
          }
        end

        it { expect(response.status).to eq(400) }
      end
    end

    describe 'GET /show' do
      let(:blog) { create(:blog) }
      let(:blog_id) { blog.id.to_s }

      let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
      end

      def perform
        get '/api/internal/blogs/' + blog_id
      end

      before do
        perform
      end

      it { expect(response.status).to eq(200) }

      context 'with resource not found' do
        let(:blog_id) { '666' }

        it { expect(response.status).to eq(404) }
      end
    end

    describe 'PUT /update' do
      let(:blog) { create(:blog) }
      let(:blog_id) { blog.id.to_s }

      let(:params) do
        {
          blog: {
            title: 'Some title'
          }
        }
      end

      let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
      end

      def perform
        put '/api/internal/blogs/' + blog_id, params: params
      end

      before do
        perform
      end

      it { expect(attributes).to include(params[:blog]) }
      it { expect(response.status).to eq(200) }

      context 'with invalid attributes' do
        let(:params) do
          {
            blog: {
              title: nil
            }
          }
        end

        it { expect(response.status).to eq(400) }
      end

      context 'with resource not found' do
        let(:blog_id) { '666' }

        it { expect(response.status).to eq(404) }
      end
    end

    describe 'DELETE /destroy' do
      let(:blog) { create(:blog) }
      let(:blog_id) { blog.id.to_s }

      def perform
        get '/api/internal/blogs/' + blog_id
      end

      before do
        perform
      end

      it { expect(response.status).to eq(200) }

      context 'with resource not found' do
        let(:blog_id) { '666' }

        it { expect(response.status).to eq(404) }
      end
    end
  end

  ```
- A swagger schema definition under `/your_api/spec/swagger/v1/schemas/blog_schema.rb` (only for exposed mode)
  ```ruby
  BLOG_SCHEMA = {
    type: :object,
    properties: {
      id: { type: :integer, example: 666 },
      title: { type: :string, example: 'Some title' },
      body: { type: :string, example: 'Some body' },
      created_at: { type: :string, example: '1984-06-04 09:00', 'x-nullable': true },
      updated_at: { type: :string, example: '1984-06-04 09:00', 'x-nullable': true },
      portfolio_id: { type: :integer, example: 666, 'x-nullable': true }
    },
    required: [
      :title,
      :body
    ]
  }

  BLOGS_COLLECTION_SCHEMA = {
    type: "object",
    properties: {
      blogs: {
        type: "array",
        items: { "$ref" => "#/definitions/blog" }
      }
    },
    required: [
      :blogs
    ]
  }

  BLOG_RESOURCE_SCHEMA = {
    type: "object",
    properties: {
      blog: { "$ref" => "#/definitions/blog" }
    },
    required: [
      :blog
    ]
  }
  ```
- An edited version of `your_api/api_example/spec/swagger/v1/definition.rb` with the schema definitions for the `Blog` resource. (only for exposed mode)
  ```ruby
  API_V1 = {
    swagger: '2.0',
    info: {
      title: 'API V1',
      version: 'v1'
    },
    basePath: '/api/v1',
    definitions: {
      blog: BLOG_SCHEMA,
      blogs_collection: BLOGS_COLLECTION_SCHEMA,
      blog_resource: BLOG_RESOURCE_SCHEMA,
    }
  }
  ```

#### Command options (valid for internal and exposed modes):

##### `--attributes`

Use this option if you want to choose which attributes of your model to add to the API response.

```bash
rails g power_api:controller blog --attributes=title
```

When you do this, you will see permited_params, serializers, swagger definitions, etc. showing only the selected attributes

For example, the serializer under `/your_api/app/serializers/api/exposed/v1/blog_serializer.rb` will show:
```ruby
class Api::Exposed::V1::BlogSerializer < ActiveModel::Serializer
  type :blog

  attributes(
    :title,
  )
end
```

##### `--controller-actions`

Use this option if you want to choose which actions will be included in the controller.

```bash
rails g power_api:controller blog --controller-actions=show destroy
```

When you do this, you will see that only relevant code is generated in controller, tests and routes.

For example, the controller would only include the `show` and `destroy` actions and wouldn't include the `blog_params` method:

```ruby
class Api::Exposed::V1::BlogController < Api::Exposed::V1::BaseController
  def show
    respond_with blog
  end

  def destroy
    respond_with blog.destroy!
  end

  private

  def blog
    @blog ||= Blog.find_by!(id: params[:id])
  end
end
```

##### `--version-number`

Use this option if you want to decide which version the new controller will belong to.

```bash
rails g power_api:controller blog --version-number=2
```

> Important! When working with exposed api you should always specify the version, otherwise the controller will be generated for the internal api mode.

##### `--use-paginator`

Use this option if you want to paginate the index endpoint collection.

```bash
rails g power_api:controller blog --use-paginator
```

The controller under `/your_api/app/controllers/api/exposed/v1/blogs_controller.rb` will be modified to use the paginator like this:

```ruby
class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
  def index
    respond_with paginate(Blog.all)
  end

  # more code...
end
```

Due to the API Pagination gem the `X-Total`, `X-Per-Page` and `X-Page` headers will be added to the answer. The parameters `params[:page][:number]` and `params[:page][:size]` can also be passed through the query string to access the different pages.

Because the AMS gem is set with "json api" format, links related to pagination will be added to the API response.

##### `--allow-filters`

Use this option if you want to filter your index endpoint collection with [Ransack](https://github.com/activerecord-hackery/ransack)

```bash
rails g power_api:controller blog --allow-filters
```

The controller under `/your_api/app/controllers/api/exposed/v1/blogs_controller.rb` will be modified like this:

```ruby
class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
  def index
    respond_with filtered_collection(Blog.all)
  end

  # more code...
end
```

The `filtered_collection` method is defined inside the gem and uses ransack below.
You will be able to filter the results according to this: https://github.com/activerecord-hackery/ransack#search-matchers

For example:

`http://localhost:3000/api/v1/blogs?q[id_gt]=22`

to search blogs with id greater than 22

##### `--authenticate-with`

Use this option if you want to have authorized resources.

> To learn more about the authentication method used please read more about [Simple Token Authentication](https://github.com/gonzalo-bulnes/simple_token_authentication) gem.

```bash
rails g power_api:controller MODEL_NAME --authenticate-with=ANOTHER_MODEL_NAME
```

Example:

```bash
rails g power_api:controller blog --authenticate-with=user
```

When you do this your controller will have the following line:

```ruby
class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
  acts_as_token_authentication_handler_for User, fallback: :exception

  # mode code...
end
```

> With internal mode a `before_action :authenticate_user!` statement will be added instead of `acts_as_token_authentication_handler_for` in order to work with devise gem directly.

In addition, the specs under `/your_api/spec/integration/api/v1/blogs_spec.rb` will add tests related with authorization.

```ruby
response '401', 'user unauthorized' do
  let(:user_token) { 'invalid' }

  run_test!
end
```

##### `--owned-by-authenticated-resource`

If you have an authenticated resource you can choose your new resource be owned by the authenticated one.

```bash
rails g power_api:controller blog --authenticate-with=user --owned-by-authenticated-resource
```

The controller will look like this:

```ruby
class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
  acts_as_token_authentication_handler_for User, fallback: :exception

  def index
    respond_with blogs
  end

  def show
    respond_with blog
  end

  def create
    respond_with blogs.create!(blog_params)
  end

  def update
    respond_with blog.update!(blog_params)
  end

  def destroy
    respond_with blog.destroy!
  end

  private

  def blog
    @blog ||= blogs.find_by!(id: params[:id])
  end

  def blogs
    @blogs ||= current_user.blogs
  end

  def blog_params
    params.require(:blog).permit(
      :id,
      :title,
      :body
    )
  end
end
```

As you can see the resource (`blog`) will always come from the authorized one (`current_user.blogs`)

To make this possible, the models should be related as follows:

```ruby
class Blog < ApplicationRecord
  belongs_to :user
end

class User < ApplicationRecord
  has_many :blogs
end
```

##### `--parent-resource`

Assuming we have the following models,

```ruby
class Blog < ApplicationRecord
  has_many :comments
end

class Comment < ApplicationRecord
  belongs_to :blog
end
```

we can run the following code to handle nested resources:

```ruby
rails g power_api:controller comment --attributes=body --parent-resource=blog
```

Running the previous code we will get:

- The controller under `/your_api/app/controllers/api/exposed/v1/comments_controller.rb`:
  ```ruby
  class Api::Exposed::V1::CommentsController < Api::Exposed::V1::BaseController
    def index
      respond_with comments
    end

    def show
      respond_with comment
    end

    def create
      respond_with comments.create!(comment_params)
    end

    def update
      respond_with comment.update!(comment_params)
    end

    def destroy
      respond_with comment.destroy!
    end

    private

    def comment
      @comment ||= Comment.find_by!(id: params[:id])
    end

    def comments
      @comments ||= blog.comments
    end

    def blog
      @blog ||= Blog.find_by!(id: params[:blog_id])
    end

    def comment_params
      params.require(:comment).permit(
        :id,
        :body
      )
    end
  end
  ```
  As you can see the `comments` used on `index` and `create` will always come from `blog` (the parent resource)

- A modified `/your_api/config/routes.rb` file with the nested resource:
  ```ruby
  Rails.application.routes.draw do
    scope path: '/api' do
      api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
        resources :comments, only: [:show, :update, :destroy]
        resources :blogs do
          resources :comments, only: [:index, :create]
        end
      end
    end
  end
  ```
- A spec file under `/your_api/spec/integration/api/v1/blogs_spec.rb` reflecting the nested resources:
  ```ruby
  require 'swagger_helper'

  describe 'API V1 Comments', swagger_doc: 'v1/swagger.json' do
    let(:blog) { create(:blog) }
    let(:blog_id) { blog.id }

    path '/blogs/{blog_id}/comments' do
      parameter name: :blog_id, in: :path, type: :integer
      get 'Retrieves Comments' do
        description 'Retrieves all the comments'
        produces 'application/json'

        let(:collection_count) { 5 }
        let(:expected_collection_count) { collection_count }

        before { create_list(:comment, collection_count, blog: blog) }

        response '200', 'Comments retrieved' do
          schema('$ref' => '#/definitions/comments_collection')

          run_test! do |response|
            expect(JSON.parse(response.body)['data'].count).to eq(expected_collection_count)
          end
        end
      end
    end

    # more code...
  end
  ```
> Note that the options: `--parent-resource` and `--owned-by-authenticated-resource` cannot be used together.

## Inside the gem

```ruby
module PowerApi
  class BaseController < ApplicationController
    include Api::Error
    include Api::Deprecated

    self.responder = ApiResponder

    respond_to :json
  end
end
```

The `PowerApi::BaseController` class that exists inside this gem and is inherited by the base class of your API (`/your_app/app/controllers/api/base_controller.rb`) includes functionality that I will describe bellow:

### The `Api::Error` concern

This module handles common exceptions like:

- `ActiveRecord::RecordNotFound`
- `ActiveModel::ForbiddenAttributesError`
- `ActiveRecord::RecordInvalid`
- `PowerApi::InvalidVersion`
- `Exception`

If you want to handle new errors, this can be done by calling the `respond_api_error` method in the base class of your API like this:

```ruby
class Api::BaseController < PowerApi::BaseController
  rescue_from "MyCustomErrorClass" do |exception|
    respond_api_error(:bad_request, message: "some error message", detail: exception.message)
  end
end
```

### The `Api::Deprecated` concern

This module is useful when you want to mark endpoints as deprecated.

For example, if you have the following controller:

```ruby
class Api::Exposed::V1::CommentsController < Api::Exposed::V1::BaseController
  deprecate :index

  def index
    respond_with comments
  end

  # more code...
end
```

And then in your browser you execute: `GET /api/v1/comments`, you will get a `Deprecated: true` response header.

This is useful to notify your customers that an endpoint will not be available in the next version of the API.

### The `ApiResponder`

It look like this:

```ruby
class ApiResponder < ActionController::Responder
  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?

    if delete?
      head :no_content
    elsif post?
      display resource, status: :created
    else
      display resource
    end
  end
end
```

As you can see, this simple [Responder](https://github.com/heartcombo/responders) handles the API response based on the HTTP verbs.

### The `PowerApi::ApplicationHelper#serialize_resource` helper method

This helper method is useful if you want to serialize ActiveRecord resources to use in your views. For example, you can do:

```
<pre>
  <%= serialize_resource(@resource, @options) %>
</pre>
```

To get:

```
{"id":1,"title":"lean","body":"bla","createdAt":"2022-01-08T18:15:46.624Z","updatedAt":"2022-01-08T18:15:46.624Z","portfolioId":null}
```

The `@resource` parameter must be an ActiveRecord instance (`ApplicationRecord`) or collection (`ActiveRecord_Relation`).

The `@options` parameter must be a `Hash` and can contain the options you commonly use with Active Model Serializer gem (`fields`, `transform_key`, etc.) and some others:
- `include_root`: to get something like: `{"id":1,"title":"lean"}` or `{"blog": {"id":1,"title":"lean"}}`.
- `output`: can be `:hash` or `:json`.

## Testing

To run the specs you need to execute, **in the root path of the gem**, the following command:

```bash
bundle exec guard
```

You need to put **all your tests** in the `/power_api/spec/dummy/spec/` directory.

## Publishing

On master/main branch...

1. Change `VERSION` in `lib/power_api/version.rb`.
2. Change `Unreleased` title to current version in `CHANGELOG.md`.
3. Run `bundle install`.
4. Commit new release. For example: `Releasing v0.1.0`.
5. Create tag. For example: `git tag v0.1.0`.
6. Push tag. For example: `git push origin v0.1.0`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/power_api/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

Power API is maintained by [platanus](http://platan.us).

## License

Power API is © 2022 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
