require 'test_helper'

class Queries::PuppetclassQueryTest < ActiveSupport::TestCase
  test 'fetching puppetclass attributes' do
    puppetclass = FactoryBot.create(:puppetclass)

    query = <<-GRAPHQL
      query {
        puppetclass(id: #{puppetclass.id}) {
          id
          name
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_puppetclass_attributes = {
      'id' => puppetclass.id,
      'name' => puppetclass.name
    }

    assert_equal expected_puppetclass_attributes, result['data']['puppetclass']
  end
end
