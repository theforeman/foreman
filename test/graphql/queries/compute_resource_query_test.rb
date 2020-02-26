require 'test_helper'

module Queries
  class ComputeResourceQueryTest < GraphQLQueryTestCase
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
          networks {
            totalCount
            edges {
              node {
                __typename
                ... on Vmware {
                  id
                  name
                  virtualswitch
                  datacenter
                  accessible
                  vlanid
                }
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
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['computeResource'] }

    setup do
      RecordLoader.any_instance.expects(:load_by_global_id).returns(compute_resource)
      Fog.mock!
      FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
    end

    teardown { Fog.unmock! }

    test 'fetching compute resource attributes' do
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

    test 'fetching compute resource VMWare networks' do
      assert compute_resource.networks.any?
      assert_equal compute_resource.networks.count, data['networks']['totalCount']
      assert_same_elements compute_resource.networks.map(&:id), data['networks']['edges'].map { |e| e['node']['id'] }

      network = compute_resource.networks.first
      edge = data['networks']['edges'].find { |e| e['node']['id'] == network.id }['node']

      assert_equal 'Vmware', edge['__typename']
      assert_equal network.id, edge['id']
      assert_equal network.name, edge['name']
      assert_equal network.virtualswitch, edge['virtualswitch']
      assert_equal network.datacenter, edge['datacenter']
      assert_equal network.accessible, edge['accessible']
      assert_equal network.vlanid, edge['vlanid']
    end
  end
end
