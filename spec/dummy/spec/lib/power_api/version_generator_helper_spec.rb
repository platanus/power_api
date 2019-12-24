require "rails_helper"

describe PowerApi::VersionGeneratorHelper do
  subject { described_class.new(init_params) }

  let(:version_number) { "1" }
  let(:init_params) do
    {
      version_number: version_number
    }
  end
end
