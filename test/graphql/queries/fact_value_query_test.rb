require 'test_helper'

module Queries
  class FactValueQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        factValue(id: $id) {
          id
          createdAt
          updatedAt
          value
          factName {
            id
          }
          host {
            id
          }
        }
      }
      GRAPHQL
    end

    let(:fact_value) { FactoryBot.create(:fact_value) }

    let(:global_id) { Foreman::GlobalId.for(fact_value) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['factValue'] }

    test 'fetching fact value attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal fact_value.created_at.utc.iso8601, data['createdAt']
      assert_equal fact_value.updated_at.utc.iso8601, data['updatedAt']
      assert_equal fact_value.value, data['value']

      assert_record fact_value.fact_name, data['factName']
      assert_record fact_value.host, data['host'], type_name: 'Host'
    end
  end
end
