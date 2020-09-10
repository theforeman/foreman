require 'test_helper'

module Queries
  class BookmarksQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          bookmarks {
            totalCount
            edges {
              node {
                id
                name
                controller
                query
                public
              }
            }
          }
        }
      GRAPHQL
    end

    let(:data) { result['data']['bookmarks'] }

    setup do
      FactoryBot.create(:bookmark, :owner => users(:one), :controller => 'hosts')
    end

    test 'should return a bookmarks' do
      assert_empty result['errors']
      assert_equal Bookmark.count, data['totalCount']
      assert_equal Bookmark.count, data['edges'].count
    end
  end
end
