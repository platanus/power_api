module TestGeneratorHelpers
  extend ActiveSupport::Concern

  included do
    subject(:generators_helper) { PowerApi::GeneratorHelpers.new(init_params) }

    let(:version_number) { "1" }
    let(:resource_name) { "blog" }
    let(:resource_attributes) { nil }
    let(:use_paginator) { false }
    let(:allow_filters) { false }

    let(:init_params) do
      {
        version_number: version_number,
        resource_name: resource_name,
        resource_attributes: resource_attributes,
        use_paginator: use_paginator,
        allow_filters: allow_filters
      }
    end
  end
end
