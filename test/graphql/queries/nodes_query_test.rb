require 'test_helper'

module Queries
  class NodesQueryTest < GraphQLQueryTestCase
    let(:model) { FactoryBot.create(:model) }
    let(:global_id) { Foreman::GlobalId.for(model) }

    test 'fetching node by relay global id' do
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

      result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

      expected_model_attributes = {
        'id' => global_id,
        'name' => model.name,
      }

      assert_empty result['errors']
      assert_equal expected_model_attributes, result['data']['node']
    end

    test 'fetching multiple nodes by relay global id' do
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

      result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

      expected_model_attributes = {
        'id' => global_id,
        'name' => model.name,
      }

      assert_empty result['errors']
      assert_equal expected_model_attributes, result['data']['nodes'].first
    end

    context 'as user without view_models permission' do
      let(:context_user) { setup_user 'view', 'hosts' }

      test 'does not fetch the record' do
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

        result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

        assert_empty result['errors']
        assert_nil result['data']['node']
      end
    end
  end
end
