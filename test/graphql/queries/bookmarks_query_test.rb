require 'test_helper'

class Queries::BookmarksQueryTest < ActiveSupport::TestCase
  test 'fetching bookmarks attributes' do
    bookmark = FactoryBot.create(:bookmark, controller: 'users')

    query = <<-GRAPHQL
      query {
        bookmarks {
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
              name
              controller
              public
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_bookmark_attributes = {
      'id' => bookmark.id,
      'name' => bookmark.name,
      'controller' => bookmark.controller,
      'public' => bookmark.public
    }

    assert_includes result['data']['bookmarks']['edges'].map { |e| e['node'] }, expected_bookmark_attributes
  end
end
