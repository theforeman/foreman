require 'test_helper'

module Queries
  class EnvironmentQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        environment(id: $id) {
          id
          createdAt
          updatedAt
          name
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

    let(:environment) { FactoryBot.create(:environment) }

    let(:global_id) { Foreman::GlobalId.for(environment) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['environment'] }

    test 'fetching environment attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal environment.created_at.utc.iso8601, data['createdAt']
      assert_equal environment.updated_at.utc.iso8601, data['updatedAt']
      assert_equal environment.name, data['name']

      assert_collection environment.locations, data['locations']
      assert_collection environment.organizations, data['organizations']
    end
  end
end
