require 'test_helper'

class Queries::FactNamesQueryTest < ActiveSupport::TestCase
  test 'fetching fact names attributes' do
    FactoryBot.create_list(:fact_name, 2)

    query = <<-GRAPHQL
      query {
        factNames {
          totalCount
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

    expected_count = FactName.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['factNames']['totalCount']
    assert_equal expected_count, result['data']['factNames']['edges'].count
  end
end
