# frozen_string_literal: true

FactoryBot.define do
  factory :infrastructure_facet, class: 'HostFacets::InfrastructureFacet' do
    foreman_uuid { SecureRandom.uuid }
    smart_proxy_uuid { SecureRandom.uuid }
    host
  end
end
