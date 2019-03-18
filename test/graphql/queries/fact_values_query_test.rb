require 'test_helper'

class Queries::FactValuesQueryTest < ActiveSupport::TestCase
  test 'fetching fact values attributes' do
    FactoryBot.create_list(:fact_value, 2)

    query = <<-GRAPHQL
      query {
        factValues {
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

    expected_count = FactValue.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['factValues']['totalCount']
    assert_equal expected_count, result['data']['factValues']['edges'].count
  end
end
