module PowerApi::GeneratorHelper::RubocopHelper
  extend ActiveSupport::Concern

  def format_ruby_file(path)
    return unless File.exist?(path)

    options, paths = RuboCop::Options.new.parse(["-a", "-fa", path])
    runner = RuboCop::Runner.new(options, RuboCop::ConfigStore.new)
    runner.run(paths)
  end
end
