require 'test_helper'

class Queries::HostQueryTest < ActiveSupport::TestCase
  test 'fetching host attributes and relations' do
    host = FactoryBot.create(
      :host,
      :managed, :on_compute_resource, :with_environment, :with_puppet,
      :with_puppet_ca, :with_puppetclass
    )
    compute_attribute = FactoryBot.create(
      :compute_attribute,
      compute_profile: FactoryBot.create(:compute_profile),
      compute_resource: host.compute_resource,
      vm_attrs: {
        cpus: 4,
        memory: 536_870_912,
        volumes_attributes: {
          '0' => { 'vol' => 1 },
          '1' => { 'vol' => 2 }
        }
      }
    )

    query = <<-GRAPHQL
      query {
        host(id: #{host.id}) {
          id
          name
          build
          createdAt
          architecture {
            id
            name
          }
          operatingsystem {
            id
            name
          }
          location {
            id
            name
          }
          environment {
            id
            name
          }
          puppetProxy {
            id
            name
          }
          puppetCaProxy {
            id
            name
          }
          puppetclasses {
            id
          }
          computeResource {
            id
            computeAttributes {
              id
              vmAttrs {
                cpus
                memory
                volumesAttributes
              }
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_host_attributes = {
      'id' => host.id,
      'name' => host.name,
      'build' => host.build,
      'createdAt' => host.created_at.utc.iso8601,
      'architecture' => { 'id' => host.architecture_id, 'name' => host.architecture.name },
      'operatingsystem' => { 'id' => host.operatingsystem_id, 'name' => host.operatingsystem.name },
      'location' => { 'id' => host.location_id, 'name' => host.location.name },
      'environment' => { 'id' => host.environment_id, 'name' => host.environment.name },
      'puppetProxy' => { 'id' => host.puppet_proxy_id, 'name' => host.puppet_proxy.name },
      'puppetCaProxy' => { 'id' => host.puppet_ca_proxy_id, 'name' => host.puppet_ca_proxy.name },
      'puppetclasses' => [{ 'id' => host.puppetclasses.first.id }],
      'computeResource' => {
        'id' => host.compute_resource.id,
        'computeAttributes' => [
          'id' => compute_attribute.id,
          'vmAttrs' => {
            'cpus' => compute_attribute.vm_attrs[:cpus].to_s,
            'memory' => compute_attribute.vm_attrs[:memory].to_s,
            'volumesAttributes' => compute_attribute.vm_attrs[:volumes_attributes]
          }
        ]
      }
    }

    assert_equal expected_host_attributes, result['data']['host']
  end
end
