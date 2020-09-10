require 'test_helper'

module Queries
  class MediumQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        medium(id: $id) {
          id
          createdAt
          updatedAt
          name
          path
          osFamily
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

    let(:medium) { FactoryBot.create(:medium, :with_operatingsystem) }

    let(:global_id) { Foreman::GlobalId.for(medium) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['medium'] }

    setup do
      FactoryBot.create(:host, :managed, medium: medium, operatingsystem: medium.operatingsystems.first, architecture: medium.operatingsystems.first.architectures.first)
    end

    test 'fetching medium attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal medium.created_at.utc.iso8601, data['createdAt']
      assert_equal medium.updated_at.utc.iso8601, data['updatedAt']
      assert_equal medium.name, data['name']
      assert_equal medium.path, data['path']
      assert_equal medium.os_family, data['osFamily']

      assert_collection medium.operatingsystems, data['operatingsystems']
      assert_collection medium.hosts, data['hosts'], type_name: 'Host'
      assert_collection medium.locations, data['locations']
      assert_collection medium.organizations, data['organizations']
    end
  end
end
