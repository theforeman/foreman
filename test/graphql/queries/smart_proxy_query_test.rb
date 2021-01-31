require 'test_helper'

module Queries
  class SmartProxyQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        smartProxy(id: $id) {
          id
          createdAt
          updatedAt
          name
          url
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
    let(:smart_proxy) { FactoryBot.create(:smart_proxy, hosts: hosts) }

    let(:global_id) { Foreman::GlobalId.for(smart_proxy) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['smartProxy'] }

    test 'fetching smart proxy attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal smart_proxy.created_at.utc.iso8601, data['createdAt']
      assert_equal smart_proxy.updated_at.utc.iso8601, data['updatedAt']
      assert_equal smart_proxy.name, data['name']
      assert_equal smart_proxy.url, data['url']

      assert_collection smart_proxy.hosts, data['hosts'], type_name: 'Host'
    end
  end
end
