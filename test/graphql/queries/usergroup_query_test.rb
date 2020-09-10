require 'test_helper'

module Queries
  class UsergroupQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        usergroup(id: $id) {
          id
          createdAt
          updatedAt
          name
          admin
          users {
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

    let(:user) { FactoryBot.create(:user, :with_usergroup) }
    let(:usergroup) { user.usergroups.first }

    let(:global_id) { Foreman::GlobalId.for(usergroup) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['usergroup'] }

    test 'fetching usergroup attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal usergroup.created_at.utc.iso8601, data['createdAt']
      assert_equal usergroup.updated_at.utc.iso8601, data['updatedAt']
      assert_equal usergroup.name, data['name']
      assert_equal usergroup.admin, data['admin']

      assert_collection [user], data['users']
    end
  end
end
