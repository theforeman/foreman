require 'test_helper'

module Queries
  class ArchitectureQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        architecture(id: $id) {
          id
          createdAt
          updatedAt
          name
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
    let(:architecture) { FactoryBot.create(:architecture, hosts: hosts) }

    let(:global_id) { Foreman::GlobalId.for(architecture) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['architecture'] }

    test 'fetching architecture attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal architecture.created_at.utc.iso8601, data['createdAt']
      assert_equal architecture.updated_at.utc.iso8601, data['updatedAt']
      assert_equal architecture.name, data['name']

      assert_collection architecture.hosts, data['hosts'], type_name: 'Host'
    end
  end
end
