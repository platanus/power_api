class PowerApi::CreateVersionGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  argument :version_number, type: :string, required: true

  def modify_routes
    return unless validate_version_number!
    return add_first_version_route if version_one?

    add_new_version_route
  end

  private

  def version_one?
    version_number.to_i == 1
  end

  def validate_version_number!
    !!Integer(version_number, 10)
  rescue ArgumentError, TypeError
    puts("Invalid version number: #{version_number}. Must be an Integer value.")
    false
  end

  def add_first_version_route
    insert_into_routes("routes.draw do\n") do
      <<-ROUTE
  scope path: '/api' do
    api_version(#{api_version_params}) do
    end
  end
      ROUTE
    end
  end

  def add_new_version_route
    insert_into_routes("'/api' do\n") do
      <<-ROUTE
    api_version(#{api_version_params}) do
    end

      ROUTE
    end
  end

  def insert_into_routes(line, &block)
    insert_into_file "config/routes.rb", after: line do
      block.call
    end
  end

  def api_version_params
    "module: 'Api::V#{version_number}', \
path: { value: 'v#{version_number}' }, \
defaults: { format: 'json' }"
  end
end
