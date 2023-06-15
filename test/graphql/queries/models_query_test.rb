require 'test_helper'

module Queries
  class ModelsQueryTest < GraphQLQueryTestCase
    let(:page_size) { 10 }

    let(:query) do
      <<-GRAPHQL
      query {
        models(first: #{page_size}) {
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
      FactoryBot.create_list(:model, 20)
    end

    test 'fetching models attributes' do
      assert_empty result['errors']

      expected_total_count = Model.count

      assert_equal expected_total_count, data['totalCount']
      assert_equal page_size, data['edges'].count
    end
  end
end
