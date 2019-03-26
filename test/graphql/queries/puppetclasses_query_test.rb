require 'test_helper'

class Queries::PuppetclassesQueryTest < ActiveSupport::TestCase
  test 'fetching puppetclasses attributes' do
    FactoryBot.create_list(:puppetclass, 2)

    query = <<-GRAPHQL
      query {
        puppetclasses {
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

    expected_count = Puppetclass.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['puppetclasses']['totalCount']
    assert_equal expected_count, result['data']['puppetclasses']['edges'].count
  end
end
