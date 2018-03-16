require 'test_helper'

class Queries::EnvironmentsQueryTest < ActiveSupport::TestCase
  test 'fetching environment attributes' do
    environment = FactoryBot.create(:environment)

    query = <<-GRAPHQL
      query {
        environments {
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_environment_attributes = {
      'id' => environment.id,
      'name' => environment.name
    }

    assert_includes(
      result['data']['environments']['edges'].map { |e| e['node'] },
      expected_environment_attributes
    )
  end
end
