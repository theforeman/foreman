require 'test_helper'

class Queries::DomainsQueryTest < ActiveSupport::TestCase
  test 'fetching domains attributes' do
    FactoryBot.create_list(:domain, 2)

    query = <<-GRAPHQL
      query {
        domains {
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

    expected_count = Domain.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['domains']['totalCount']
    assert_equal expected_count, result['data']['domains']['edges'].count
  end
end
