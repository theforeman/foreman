require 'test_helper'

class Queries::ModelQueryTest < ActiveSupport::TestCase
  test 'fetching model attributes' do
    model = FactoryBot.create(:model)

    query = <<-GRAPHQL
      query modelQuery (
        $id: String!
      ) {
        model(id: $id) {
          id
          name
          info
          vendorClass
          hardwareModel
        }
      }
    GRAPHQL

    model_global_id = Foreman::GlobalId.for(model)
    context = { current_user: FactoryBot.create(:user, :admin) }
    variables = { id: model_global_id }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)

    expected_model_attributes = {
      'id' => model_global_id,
      'name' => model.name,
      'info' => model.info,
      'vendorClass' => model.vendor_class,
      'hardwareModel' => model.hardware_model
    }

    assert_empty result['errors']
    assert_equal expected_model_attributes, result['data']['model']
  end
end
