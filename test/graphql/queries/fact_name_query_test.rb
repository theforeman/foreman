require 'test_helper'

module Queries
  class FactNameQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        factName(id: $id) {
          id
          createdAt
          updatedAt
          shortName
          type
          factValues {
            totalCount
            edges {
              node {
                id
              }
            }
          }
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
    end

    let(:fact_value) { FactoryBot.create(:fact_value) }
    let(:fact_name) { fact_value.fact_name }

    let(:global_id) { Foreman::GlobalId.for(fact_name) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['factName'] }

    test 'fetching fact name attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal fact_name.created_at.utc.iso8601, data['createdAt']
      assert_equal fact_name.updated_at.utc.iso8601, data['updatedAt']
      assert_equal fact_name.short_name, data['shortName']
      assert_equal fact_name.type, data['type']

      assert_collection fact_name.fact_values, data['factValues']
      assert_collection fact_name.hosts, data['hosts'], type_name: 'Host'
    end
  end
end
