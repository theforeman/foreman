require 'test_helper'

class Queries::ModelsQueryTest < ActiveSupport::TestCase
  test 'fetching models attributes and relations' do
    FactoryBot.create_list(:model, 2)

    query = <<-GRAPHQL
      query modelsQuery {
        models {
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
    assert_equal Model.count, result['data']['models']['edges'].count
  end
end
