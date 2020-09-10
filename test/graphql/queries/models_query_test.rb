require 'test_helper'

module Queries
  class ModelsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        models {
          totalCount
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
            }
          }
        }
      }
      GRAPHQL
    end

    let(:data) { result['data']['models'] }

    setup do
      FactoryBot.create_list(:model, 2)
    end

    test 'fetching models attributes' do
      assert_empty result['errors']

      expected_count = Model.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
