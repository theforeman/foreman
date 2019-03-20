require 'test_helper'

class Queries::FactValueQueryTest < ActiveSupport::TestCase
  test 'fetching fact value attributes' do
    fact_value = FactoryBot.create(:fact_value)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        factValue(id: $id) {
          id
          createdAt
          updatedAt
          value
          factName {
            id
          }
          host {
            id
          }
        }
      }
    GRAPHQL

    fact_value_global_id = Foreman::GlobalId.for(fact_value)
    variables = { id: fact_value_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'factValue' => {
        'id' => fact_value_global_id,
        'createdAt' => fact_value.created_at.utc.iso8601,
        'updatedAt' => fact_value.updated_at.utc.iso8601,
        'value' => fact_value.value,
        'factName' => {
          'id' => Foreman::GlobalId.for(fact_value.fact_name)
        },
        'host' => {
          'id' => Foreman::GlobalId.encode('Host', fact_value.host.id)
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
