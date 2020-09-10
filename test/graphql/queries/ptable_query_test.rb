require 'test_helper'

module Queries
  class PtableQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        ptable(id: $id) {
          id
          createdAt
          updatedAt
          name
          locked
          operatingsystems {
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
          locations {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          organizations {
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
    let(:operatingsystem) { FactoryBot.create(:operatingsystem) }
    let(:ptable) { FactoryBot.create(:ptable, hosts: hosts, operatingsystems: [operatingsystem]) }

    let(:global_id) { Foreman::GlobalId.for(ptable) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['ptable'] }

    test 'fetching ptable attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal ptable.created_at.utc.iso8601, data['createdAt']
      assert_equal ptable.updated_at.utc.iso8601, data['updatedAt']
      assert_equal ptable.name, data['name']
      assert_equal ptable.locked, data['locked']

      assert_collection ptable.operatingsystems, data['operatingsystems']
      assert_collection ptable.hosts, data['hosts'], type_name: 'Host'
      assert_collection ptable.locations, data['locations']
      assert_collection ptable.organizations, data['organizations']
    end
  end
end
