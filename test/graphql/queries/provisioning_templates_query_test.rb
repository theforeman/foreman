require 'test_helper'

module Queries
  class ProvisioningTemplateQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        provisioningTemplates {
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

    let(:data) { result['data']['provisioningTemplates'] }

    setup do
      FactoryBot.create_list(:provisioning_template, 2)
    end

    test 'fetching provisioningTemplates attributes' do
      assert_empty result['errors']

      expected_count = ProvisioningTemplate.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
