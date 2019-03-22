class PowerApi::VersionGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  argument :version_number, type: :string, required: true

  def modify_routes
    return unless version_number_valid?

    version_one? ? add_first_version_route : add_new_version_route
    add_base_controller
    add_serializers_directory
  end

  private

  def version_one?
    version_number.to_i == 1
  end

  def version_number_valid?
    !!Integer(version_number, 10)

    if !version_number.to_i.positive?
      puts("Vesion number must be greater than 0")
      return false
    end

    true
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

  def add_base_controller
    template(
      "version_base_controller.rb.erb",
      "app/controllers/api/v#{version_number}/base_controller.rb"
    )
  end

  def add_serializers_directory
    create_file "app/serializers/api/v#{version_number}/.gitkeep"
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
