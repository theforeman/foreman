require 'test_helper'

module Queries
  class PuppetclassesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        puppetclasses {
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

    let(:data) { result['data']['puppetclasses'] }

    setup do
      FactoryBot.create_list(:puppetclass, 2)
    end

    test 'fetching puppetclasses attributes' do
      assert_empty result['errors']

      expected_count = Puppetclass.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
