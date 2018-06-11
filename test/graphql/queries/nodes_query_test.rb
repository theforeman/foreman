require 'test_helper'

class Queries::NodesQueryTest < ActiveSupport::TestCase
  test 'fetching node by relay global id' do
    model = FactoryBot.create(:model)
    global_id = Foreman::GlobalId.encode('Model', model.id)

    query = <<-GRAPHQL
      query getNode {
        node(id: #{global_id}) {
          id
          ... on Model {
            name
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_model_attributes = {
      'id' => global_id,
      'name' => model.name
    }

    assert_empty result['errors']
    assert_equal expected_model_attributes, result['data']['node']
  end

  test 'fetching multiple nodes by relay global id' do
    model = FactoryBot.create(:model)
    global_id = Foreman::GlobalId.encode('Model', model.id)

    query = <<-GRAPHQL
      query getNodes {
        nodes(ids: [#{global_id}]) {
          id
          ... on Model {
            name
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_model_attributes = {
      'id' => global_id,
      'name' => model.name
    }

    assert_empty result['errors']
    assert_equal expected_model_attributes, result['data']['nodes'].first
  end
end
