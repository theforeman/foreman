require 'test_helper'

class Queries::ArchitecturesQueryTest < ActiveSupport::TestCase
  test 'fetching architectures attributes' do
    FactoryBot.create_list(:architecture, 2)

    query = <<-GRAPHQL
      query {
        architectures {
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
    assert_equal Architecture.count, result['data']['architectures']['edges'].count
  end
end
