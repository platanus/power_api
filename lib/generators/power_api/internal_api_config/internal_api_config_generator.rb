class PowerApi::InternalApiConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new
  end
end
