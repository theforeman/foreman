require 'test_helper'

class Queries::HostQueryTest < ActiveSupport::TestCase
  test 'fetching host attributes' do
    host = FactoryBot.create(:host, :managed, :with_model, :with_facts)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        host(id: $id) {
          id
          createdAt
          updatedAt
          name
          model {
            id
          }
          factNames {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          factValues {
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

    host_global_id = Foreman::GlobalId.encode('Host', host.id)
    variables = { id: host_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'host' => {
        'id' => host_global_id,
        'createdAt' => host.created_at.utc.iso8601,
        'updatedAt' => host.updated_at.utc.iso8601,
        'name' => host.name,
        'model' => {
          'id' => Foreman::GlobalId.for(host.model)
        },
        'factNames' => {
          'totalCount' => host.fact_names.count,
          'edges' => host.fact_names.sort_by(&:id).map do |fact_name|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(fact_name)
              }
            }
          end
        },
        'factValues' => {
          'totalCount' => host.fact_values.count,
          'edges' => host.fact_values.map do |fact_value|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(fact_value)
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
