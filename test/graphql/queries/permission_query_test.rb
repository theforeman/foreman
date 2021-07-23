require 'test_helper'

module Queries
  class PermissionQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        permission(id: $id) {
          id
          createdAt
          updatedAt
          name
        }
      }
      GRAPHQL
    end

    let(:permission) { Permission.last }

    let(:global_id) { Foreman::GlobalId.for(permission) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['permission'] }

    test 'fetching permission attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal permission.name, data['name']
    end
  end
end
