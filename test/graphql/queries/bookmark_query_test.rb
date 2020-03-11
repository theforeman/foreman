require 'test_helper'

module Queries
  class BookmarkQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query($id:String!) {
          bookmark(id: $id) {
            id
            name
            controller
            query
            public
            owner {
              ... on User {
                login
              }
            }
          }
        }
      GRAPHQL
    end

    let(:bookmark) { FactoryBot.create(:bookmark, :owner => users(:one), :controller => 'hosts') }

    let(:global_id) { Foreman::GlobalId.for(bookmark) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['bookmark'] }

    test 'should return a bookmark' do
      assert_empty result['errors']
      assert_equal global_id, data['id']
      assert_equal bookmark.query, data['query']
      assert_equal bookmark.public, data['public']
      assert_equal bookmark.owner.login, data['owner']['login']
    end
  end
end
