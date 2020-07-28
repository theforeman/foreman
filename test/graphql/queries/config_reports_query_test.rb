require 'test_helper'

module Queries
  class ConfigReportsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          configReports {
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
                createdAt
                updatedAt
                metrics
                status
                origin
              }
            }
          }
        }
      GRAPHQL
    end

    let(:data) { result['data']['configReports'] }

    setup do
      host = FactoryBot.create(:host)
      FactoryBot.create(:report, :host_id => host.id)
    end

    test 'fetch config reports' do
      assert_empty result['errors']

      expected_count = ConfigReport.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
