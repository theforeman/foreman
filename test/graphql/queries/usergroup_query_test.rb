require 'test_helper'

class Queries::UsergroupQueryTest < ActiveSupport::TestCase
  test 'fetching usergroup attributes' do
    usergroup = FactoryBot.create(:usergroup)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        usergroup(id: $id) {
          id
          createdAt
          updatedAt
          name
          admin
        }
      }
    GRAPHQL

    usergroup_global_id = Foreman::GlobalId.for(usergroup)
    variables = { id: usergroup_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'usergroup' => {
        'id' => usergroup_global_id,
        'createdAt' => usergroup.created_at.utc.iso8601,
        'updatedAt' => usergroup.updated_at.utc.iso8601,
        'name' => usergroup.name,
        'admin' => usergroup.admin
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
