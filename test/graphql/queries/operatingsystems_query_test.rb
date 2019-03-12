require 'test_helper'

class Queries::OperatingsystemsQueryTest < ActiveSupport::TestCase
  test 'fetching operatingsystems attributes' do
    FactoryBot.create_list(:operatingsystem, 2)

    query = <<-GRAPHQL
      query {
        operatingsystems {
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
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }
    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    assert_empty result['errors']
    assert_equal Operatingsystem.count, result['data']['operatingsystems']['edges'].count
  end
end
