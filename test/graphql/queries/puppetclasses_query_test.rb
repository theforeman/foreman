require 'test_helper'

class Queries::PuppetclassQueryTest < ActiveSupport::TestCase
  test 'fetching puppetclass attributes' do
    puppetclass = FactoryBot.create(:puppetclass)

    query = <<-GRAPHQL
      query {
        puppetclasses {
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

    expected_puppetclass_attributes = {
      'id' => puppetclass.id,
      'name' => puppetclass.name
    }

    assert_includes(
      result['data']['puppetclasses']['edges'].map { |e| e['node'] },
      expected_puppetclass_attributes
    )
  end
end
