require 'test_helper'

class Queries::ModelQueryTest < ActiveSupport::TestCase
  test 'fetching model attributes' do
    host = FactoryBot.create(:host, :with_model)
    # Create a host that is not associated to the model
    # so we can test it does not show up in the result
    FactoryBot.create(:host, :managed)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        model(id: $id) {
          id
          createdAt
          updatedAt
          name
          info
          vendorClass
          hardwareModel
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

    model_global_id = Foreman::GlobalId.for(host.model)
    variables = { id: model_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)

    expected = {
      'model' => {
        'id' => model_global_id,
        'createdAt' => host.model.created_at.utc.iso8601,
        'updatedAt' => host.model.updated_at.utc.iso8601,
        'name' => host.model.name,
        'info' => host.model.info,
        'vendorClass' => host.model.vendor_class,
        'hardwareModel' => host.model.hardware_model,
        'hosts' => {
          'totalCount' => 1,
          'edges' => [
            {
              'node' => {
                'id' => Foreman::GlobalId.encode('Host', host.id)
              }
            }
          ]
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
