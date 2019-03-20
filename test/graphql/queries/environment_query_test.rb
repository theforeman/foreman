require 'test_helper'

class Queries::EnvironmentQueryTest < ActiveSupport::TestCase
  test 'fetching environment attributes' do
    environment = FactoryBot.create(:environment)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        environment(id: $id) {
          id
          createdAt
          updatedAt
          name
        }
      }
    GRAPHQL

    environment_global_id = Foreman::GlobalId.for(environment)
    variables = { id: environment_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'environment' => {
        'id' => environment_global_id,
        'createdAt' => environment.created_at.utc.iso8601,
        'updatedAt' => environment.updated_at.utc.iso8601,
        'name' => environment.name
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
