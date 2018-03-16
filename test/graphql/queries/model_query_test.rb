require 'test_helper'

class Queries::ModelQueryTest < ActiveSupport::TestCase
  test 'fetching model attributes' do
    model = FactoryBot.create(:model)

    query = <<-GRAPHQL
      query {
        model(id: #{model.id}) {
          id
          name
          info
          vendorClass
          hardwareModel
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_model_attributes = {
      'id' => model.id,
      'name' => model.name,
      'info' => model.info,
      'vendorClass' => model.vendor_class,
      'hardwareModel' => model.hardware_model
    }

    assert_equal expected_model_attributes, result['data']['model']
  end
end
