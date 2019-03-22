require 'test_helper'

class Queries::FactNameQueryTest < ActiveSupport::TestCase
  test 'fetching fact name attributes' do
    fact_value = FactoryBot.create(:fact_value)
    fact_name = fact_value.fact_name

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        factName(id: $id) {
          id
          createdAt
          updatedAt
          shortName
          type
          factValues {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          hosts {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
    GRAPHQL

    fact_name_global_id = Foreman::GlobalId.for(fact_name)
    variables = { id: fact_name_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'factName' => {
        'id' => fact_name_global_id,
        'createdAt' => fact_name.created_at.utc.iso8601,
        'updatedAt' => fact_name.updated_at.utc.iso8601,
        'shortName' => fact_name.short_name,
        'type' => fact_name.type,
        'factValues' => {
          'totalCount' => fact_name.fact_values.count,
          'edges' => fact_name.fact_values.map do |fv|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(fv)
              }
            }
          end
        },
        'hosts' => {
          'totalCount' => fact_name.hosts.count,
          'edges' => fact_name.hosts.sort_by(&:id).map do |host|
            {
              'node' => {
                'id' => Foreman::GlobalId.encode('Host', host.id)
              }
            }
          end
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
