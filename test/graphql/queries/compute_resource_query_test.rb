require 'test_helper'

class Queries::ComputeResourceQueryTest < GraphQLQueryTestCase
  let(:query) do
    <<-GRAPHQL
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
  end

  let(:hosts) { FactoryBot.create_list(:host, 2) }
  let(:compute_resource) { FactoryBot.create(:vmware_cr, uuid: 'Solutions', hosts: hosts) }

  let(:global_id) { Foreman::GlobalId.encode('ComputeResource', compute_resource.id) }
  let(:variables) {{ id: global_id }}
  let(:data) { result['data']['computeResource'] }

  setup do
    FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
  end

  test 'fetching compute resource attributes' do
    Queries::AuthorizedModelQuery.any_instance.expects(:find_by_global_id).returns(compute_resource)

    assert_empty result['errors']

    assert_equal global_id, data['id']
    assert_equal compute_resource.created_at.utc.iso8601, data['createdAt']
    assert_equal compute_resource.updated_at.utc.iso8601, data['updatedAt']
    assert_equal compute_resource.name, data['name']
    assert_equal compute_resource.description, data['description']
    assert_equal compute_resource.url, data['url']
    assert_equal compute_resource.provider, data['provider']
    assert_equal compute_resource.provider_friendly_name, data['providerFriendlyName']

    assert_collection compute_resource.compute_attributes, data['computeAttributes']
    assert_collection compute_resource.hosts, data['hosts'], type_name: 'Host'
  end
end
