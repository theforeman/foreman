require 'test_helper'

class Queries::SmartProxyQueryTest < ActiveSupport::TestCase
  test 'fetching smartProxy attributes' do
    smart_proxy = FactoryBot.create(:smart_proxy)

    query = <<-GRAPHQL
      query {
        smartProxy(id: #{smart_proxy.id}) {
          id
          name
          url
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_smart_proxy_attributes = {
      'id' => smart_proxy.id,
      'name' => smart_proxy.name,
      'url' => smart_proxy.url
    }

    assert_equal expected_smart_proxy_attributes, result['data']['smartProxy']
  end
end
