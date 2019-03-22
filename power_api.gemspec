$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "power_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "power_api"
  s.version       = PowerApi::VERSION
  s.authors       = ["Platanus", "Leandro Segovia"]
  s.email         = ["rubygems@platan.us", "ldlsegovia@gmail.com"]
  s.homepage      = "https://github.com/platanus/power_api"
  s.summary       = "Set of other gems and configurations designed to build incredible APIs"
  s.description   = "It is a Rails engine that gathers a set of other gems and configurations designed to build incredible APIs"
  s.license       = "MIT"

  s.files = `git ls-files`.split($/).reject { |fn| fn.start_with? "spec" }
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.2.0"

  s.add_dependency "active_model_serializers", "~> 0.10.0"
  s.add_dependency "responders"
  s.add_dependency "rswag-api"
  s.add_dependency "rswag-specs"
  s.add_dependency "rswag-ui"
  s.add_dependency "simple_token_authentication", "~> 1.0"
  s.add_dependency "versionist", "~> 1.0"

  s.add_development_dependency "coveralls"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3", "~> 1.3.0"
end
