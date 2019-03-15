require 'test_helper'

class Queries::SmartProxyQueryTest < ActiveSupport::TestCase
  test 'fetching smart proxy attributes' do
    smart_proxy = FactoryBot.create(:smart_proxy)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        smartProxy(id: $id) {
          id
          createdAt
          updatedAt
          name
          url
        }
      }
    GRAPHQL

    smart_proxy_global_id = Foreman::GlobalId.for(smart_proxy)
    variables = { id: smart_proxy_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'smartProxy' => {
        'id' => smart_proxy_global_id,
        'createdAt' => smart_proxy.created_at.utc.iso8601,
        'updatedAt' => smart_proxy.updated_at.utc.iso8601,
        'name' => smart_proxy.name,
        'url' => smart_proxy.url
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
