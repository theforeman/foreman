require 'test_helper'

class Queries::ModelQueryTest < ActiveSupport::TestCase
  test 'fetching model attributes' do
    model = FactoryBot.create(:model)

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
        }
      }
    GRAPHQL

    model_global_id = Foreman::GlobalId.for(model)
    variables = { id: model_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)

    expected = {
      'model' => {
        'id' => model_global_id,
        'createdAt' => model.created_at.utc.iso8601,
        'updatedAt' => model.updated_at.utc.iso8601,
        'name' => model.name,
        'info' => model.info,
        'vendorClass' => model.vendor_class,
        'hardwareModel' => model.hardware_model
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
