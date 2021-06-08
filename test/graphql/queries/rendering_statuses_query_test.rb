require 'test_helper'

module Queries
  class RenderingStatusesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        renderingStatuses {
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

    let(:data) { result['data']['renderingStatuses'] }

    setup do
      FactoryBot.create_list(:rendering_status_combination, 2, :safemode_ok)
    end

    test 'fetching renderingStatuses attributes' do
      assert_empty result['errors']

      expected_count = HostStatus::RenderingStatus.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
