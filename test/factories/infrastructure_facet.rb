# frozen_string_literal: true

FactoryBot.define do
  factory :infrastructure_facet, class: 'HostFacets::InfrastructureFacet' do
    foreman_instance { true }
    host
  end
end
