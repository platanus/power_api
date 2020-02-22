module TestGeneratorHelpers
  extend ActiveSupport::Concern

  included do
    subject(:generators_helper) { PowerApi::GeneratorHelpers.new(init_params) }

    let(:version_number) { "1" }
    let(:resource_name) { "blog" }
    let(:authenticated_resource) { nil }
    let(:parent_resource_name) { nil }
    let(:owned_by_authenticated_resource) { false }
    let(:resource_attributes) { nil }
    let(:use_paginator) { false }
    let(:allow_filters) { false }

    let(:init_params) do
      {
        version_number: version_number,
        resource: resource_name,
        resource_attributes: resource_attributes,
        parent_resource: parent_resource_name,
        use_paginator: use_paginator,
        authenticated_resource: authenticated_resource,
        owned_by_authenticated_resource: owned_by_authenticated_resource,
        allow_filters: allow_filters
      }
    end
  end
end
