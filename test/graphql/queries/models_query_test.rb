require 'test_helper'

class Queries::ModelsQueryTest < ActiveSupport::TestCase
  test 'fetching models attributes and relations' do
    model = FactoryBot.create(:model)

    query = <<-GRAPHQL
      query modelsQuery {
        models {
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              name
              info
              vendorClass
              hardwareModel
            }
          }
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

    assert_empty result['errors']
    assert_includes result['data']['models']['edges'].map { |e| e['node'] }, expected_model_attributes
  end
end
