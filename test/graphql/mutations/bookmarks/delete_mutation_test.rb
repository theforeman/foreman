require 'test_helper'

module Mutations
  module Bookmarks
    class DeleteMutationTest < ActiveSupport::TestCase
      let(:bookmark) { FactoryBot.create(:bookmark, :controller => 'hosts') }
      let(:bookmark_id) { Foreman::GlobalId.for(bookmark) }
      let(:variables) do
        {
          id: bookmark_id,
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation DeleteBookmarkMutation($id:ID!) {
            deleteBookmark(input: { id: $id }){
              id
              errors {
                path
                message
              }
            }
          }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }

        test 'deletes a bookmark' do
          context = { current_user: user }

          bookmark

          assert_difference('::Bookmark.count', -1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['deleteBookmark']['errors']
            assert_equal bookmark_id, result['data']['deleteBookmark']['id']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          bookmark
          @user = setup_user 'view', 'bookmarks'
        end

        test 'cannot delete a bookmark' do
          context = { current_user: @user }

          assert_difference('Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
