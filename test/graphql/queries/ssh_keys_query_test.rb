require 'test_helper'

module Queries
  class SshKeysQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        sshKeys {
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

    let(:data) { result['data']['sshKeys'] }

    setup do
      FactoryBot.create_list(:ssh_key, 2)
    end

    test 'fetching sshKeys attributes' do
      assert_empty result['errors']

      expected_count = SshKey.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
