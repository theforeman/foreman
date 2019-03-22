require 'test_helper'

class Queries::ComputeResourceQueryTest < ActiveSupport::TestCase
  test 'fetching compute resource attributes' do
    hosts = FactoryBot.create_list(:host, 2)
    compute_resource = FactoryBot.create(:vmware_cr, uuid: 'Solutions', hosts: hosts)
    FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
    Queries::AuthorizedModelQuery.any_instance.expects(:find_by_global_id).returns(compute_resource)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        computeResource(id: $id) {
          id
          createdAt
          updatedAt
          name
          description
          url
          provider
          providerFriendlyName
          computeAttributes {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          hosts {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
    GRAPHQL

    compute_resource_global_id = Foreman::GlobalId.encode('ComputeResource', compute_resource.id)
    variables = { id: compute_resource_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'computeResource' => {
        'id' => compute_resource_global_id,
        'createdAt' => compute_resource.created_at.utc.iso8601,
        'updatedAt' => compute_resource.updated_at.utc.iso8601,
        'name' => compute_resource.name,
        'description' => compute_resource.description,
        'url' => compute_resource.url,
        'provider' => compute_resource.provider,
        'providerFriendlyName' => compute_resource.provider_friendly_name,
        'computeAttributes' => {
          'totalCount' => compute_resource.compute_attributes.count,
          'edges' => compute_resource.compute_attributes.sort_by(&:id).map do |ca|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(ca)
              }
            }
          end
        },
        'hosts' => {
          'totalCount' => compute_resource.hosts.count,
          'edges' => compute_resource.hosts.sort_by(&:id).map do |host|
            {
              'node' => {
                'id' => Foreman::GlobalId.encode('Host', host.id)
              }
            }
          end
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
