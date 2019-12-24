require "rails_helper"

describe PowerApi::ControllerGeneratorHelper do
  subject { described_class.new(init_params) }

  let(:version_number) { "1" }
  let(:resource_name) { "blog" }
  let(:use_paginator) { false }
  let(:allow_filters) { false }
  let(:resource_attributes) { nil }
  let(:init_params) do
    {
      version_number: version_number,
      resource_name: resource_name,
      use_paginator: use_paginator,
      allow_filters: allow_filters,
      resource_attributes: resource_attributes
    }
  end
end
