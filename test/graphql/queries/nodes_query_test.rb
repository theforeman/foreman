require 'test_helper'

module Queries
  class NodesQueryTest < GraphQLQueryTestCase
    let(:model) { as_admin { FactoryBot.create(:model) } }
    let(:global_id) { Foreman::GlobalId.for(model) }

    test 'fetching node by relay global id' do
      query = <<-GRAPHQL
      query($id: ID!) {
        node(id: $id) {
          id
          ... on Model {
            name
          }
        }
      }
      GRAPHQL

      result = ForemanGraphqlSchema.execute(query, context: context, variables: { id: global_id })

      expected_model_attributes = {
        'id' => global_id,
        'name' => model.name,
      }

      assert_empty result['errors']
      assert_equal expected_model_attributes, result['data']['node']
    end

    test 'fetching multiple nodes by relay global id' do
      query = <<-GRAPHQL
      query($ids: [ID!]!) {
        nodes(ids: $ids) {
          id
          ... on Model {
            name
          }
        }
      }
      GRAPHQL

      result = ForemanGraphqlSchema.execute(query, context: context, variables: { ids: [global_id] })

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
      query($id: ID!) {
        node(id: $id) {
          id
          ... on Model {
            name
          }
        }
      }
        GRAPHQL

        result = ForemanGraphqlSchema.execute(query, context: context, variables: { id: global_id })

        assert_empty result['errors']
        assert_nil result['data']['node']
      end
    end
  end
end
