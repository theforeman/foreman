require 'test_helper'

class Queries::BookmarkQueryTest < ActiveSupport::TestCase
  test 'fetching bookmark attributes' do
    bookmark = FactoryBot.create(:bookmark, controller: 'users')

    query = <<-GRAPHQL
      query {
        bookmark(id: #{bookmark.id}) {
          id
          name
          controller
          public
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

    assert_equal expected_bookmark_attributes, result['data']['bookmark']
  end
end
