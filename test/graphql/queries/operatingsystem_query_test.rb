require 'test_helper'

class Queries::OperatingsystemQueryTest < ActiveSupport::TestCase
  test 'fetching operatingsystem attributes' do
    operatingsystem = FactoryBot.create(:operatingsystem)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        operatingsystem(id: $id) {
          id
          createdAt
          updatedAt
          name
          title
          type
          fullname
        }
      }
    GRAPHQL

    operatingsystem_global_id = Foreman::GlobalId.for(operatingsystem)
    variables = { id: operatingsystem_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'operatingsystem' => {
        'id' => operatingsystem_global_id,
        'createdAt' => operatingsystem.created_at.utc.iso8601,
        'updatedAt' => operatingsystem.updated_at.utc.iso8601,
        'name' => operatingsystem.name,
        'title' => operatingsystem.title,
        'type' => operatingsystem.type,
        'fullname' => operatingsystem.fullname
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
